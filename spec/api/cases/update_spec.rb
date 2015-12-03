require 'app_helper'

def add_permision_to_user(user, ids, permission = 'can_execute_step')
  group   = user.groups.first
  all_ids = group.permission.send(permission) + Array(ids)
  group.permission.update! permission => all_ids
  group.save
end

describe Cases::API, versioning: true do
  let!(:user)       { create(:user) }
  let!(:guest_user) { create(:guest_user) }

  describe 'on put case' do
    context 'when has step disabled' do
      let!(:flow) do
        flow  = create(:flow, initial: true, steps: [])
        step1 = create(:step_type_form_without_fields, flow: flow)
        step2 = create(:step_type_form, flow: flow)
        field = create(:field, step: step1, title: 'user_age', field_type: 'integer')
        flow.reload
        create(:resolution_state, flow: flow)
        other_flow = create(:flow, initial: false, steps: [build(:step_type_form)])
        other_flow.publish(user)
        create(:step, flow: flow, child_flow: other_flow)
        create(:trigger, step: step1, action_type: 'disable_steps',
               action_values: [step2.id],
               trigger_conditions: [build(:trigger_condition, values: [1], field: field)])
        create(:trigger, step: step1, action_type: 'finish_flow',
               action_values: [flow.resolution_states.first.id],
               trigger_conditions: [build(:trigger_condition, values: [10], field: field)])
        flow.publish(user)
        flow.reload
      end
      let(:fields) { flow.steps.first.fields.all }
      let(:other_step) { Flow.first.steps.second }
      let(:valid_params) do
        { step_id: other_step.id,
         step_version: other_step.versions.last.id,
         fields: [{ id: fields.first.id, value: '1' }] }
      end
      let(:other_flow_valid_params) do
        { step_id: Flow.last.steps.last.id,
         step_version: Flow.last.steps.last.versions.last.id,
         fields: [{ id: Flow.last.steps.last.fields.first.id, value: '1' }] }
      end
      let!(:kase) do
        case_params = { initial_flow_id: flow.id, fields: [{ id: fields.first.id, value: '1' }] }
        add_permision_to_user(user, flow.steps.pluck(:id))
        post '/cases', case_params, auth(user)
        Case.first
      end

      context 'no authentication' do
        before { put "/cases/#{kase.id}", valid_params }
        it     { expect(response.status).to be_an_unauthorized }
      end

      context 'with authentication' do
        context 'and user can\'t see the Step on Flow' do
          let(:error) { I18n.t(:permission_denied, action: I18n.t(:create), table_name: I18n.t(:case_steps)) }

          before { put "/cases/#{kase.id}", other_flow_valid_params, auth(guest_user) }
          it     { expect(response.status).to be_a_forbidden }
          it     { expect(parsed_body).to be_an_error(error) }
        end

        context 'and user can see the Step on Flow' do
          context 'and failure' do
            context 'because case not found' do
              before { put '/cases/123456789', valid_params, auth(user) }
              it     { expect(response.status).to be_a_not_found }
              it     { expect(parsed_body).to be_an_error('Couldn\'t find Case with \'id\'=123456789 [WHERE "cases"."status" != \'inactive\']') }
            end

            context 'because step is disabled' do
              before { put "/cases/#{kase.id}", valid_params, auth(user) }
              it     { expect(response.status).to be_a_bad_request }
              it     { expect(parsed_body).to be_an_error(I18n.t(:step_is_disabled)) }
            end
          end

          context 'successfully' do
            context 'when not send data fields' do
              let(:success_params) { valid_params.merge(step_id: fields.first.step.id, fields: [{ id: fields.first.id, value: '10' }]) }
              before do
                kase.update disabled_steps: []
                add_permision_to_user(user, fields.first.step.id)
                put "/cases/#{kase.id}", valid_params.merge(fields: []), auth(user)
              end

              it { expect(response.status).to be_a_success_request }
              it { expect(parsed_body).to be_a_success_message_with(I18n.t(:started_step_success)) }
              # it { expect(parsed_body['case']).to match_hash(entity_of(kase.reload, display_type: 'full')) }

              it 'should is active the Case' do
                expect(kase.reload.status).to eql('active')
              end

              it 'should has 4 log entries' do
                expect(kase.reload.cases_log_entries.count).to eql 2
              end

              it 'should last log entries action started_step' do
                expect(kase.reload.cases_log_entries.last.action).to eql 'started_step'
              end
            end

            context 'when send data fields' do
              let(:success_params) { valid_params.merge(step_id: fields.first.step.id, fields: [{ id: fields.first.id, value: '10' }]) }
              before do
                add_permision_to_user(user, flow.steps.pluck(:id))
                put "/cases/#{kase.id}", valid_params, auth(user)
                put "/cases/#{kase.id}", success_params, auth(user)
              end

              it { expect(response.status).to be_a_success_request }
              it { expect(parsed_body).to be_a_success_message_with(I18n.t(:update_step_success)) }
              it { expect(parsed_body['case']).to be_an_entity_of(kase.reload, display_type: 'full') }

              it 'should finish the Case' do
                expect(kase.reload.status).to eql('finished')
              end

              it 'should has 4 log entries' do
                expect(kase.reload.cases_log_entries.count).to eql 4
              end
            end
          end
        end
      end
    end

    context 'when not has trigger' do
      let(:flow) do
        other_flow = create(:flow, initial: false, steps: [build(:step_type_form)])
        other_flow.publish(user)
        flow = create(:flow, initial: true)
        create(:step_type_form_without_fields, flow: flow)
        create(:field, step: flow.steps.first, title: 'user_age', field_type: 'integer')
        create(:step, flow: flow, child_flow: other_flow)
        flow.publish(user)
        flow.reload
      end
      let(:fields)     { flow.steps.first.fields.all }
      let(:other_step) { flow.steps.last.child_flow.steps.first }
      let(:valid_params) do
        { step_id: other_step.id,
         fields: [{ id: other_step.fields.first.id, value: '1' }] }
      end
      let!(:kase) do
        case_params = { initial_flow_id: flow.id,
          fields: [{ id: fields.first.id, value: '1' }] }
        add_permision_to_user(user, Step.pluck(:id))
        post '/cases', case_params, auth(user)
        Case.first
      end

      context 'no authentication' do
        before { put "/cases/#{kase.id}", valid_params }
        it     { expect(response.status).to be_an_unauthorized }
      end

      context 'with authentication' do
        context 'and user can\'t see the Step on Flow' do
          let(:error) { I18n.t(:permission_denied, action: I18n.t(:create), table_name: I18n.t(:case_steps)) }

          before { put "/cases/#{kase.id}", valid_params, auth(guest_user) }
          it     { expect(response.status).to be_a_forbidden }
          it     { expect(parsed_body).to be_an_error(error) }
        end

        context 'and user can execute first Step on Flow' do
          context 'and failure' do
            context 'because case not found' do
              before { put '/cases/123456789', valid_params, auth(user) }
              it     { expect(response.status).to be_a_not_found }
              it     { expect(parsed_body).to be_an_error('Couldn\'t find Case with \'id\'=123456789 [WHERE "cases"."status" != \'inactive\']') }
            end
          end

          context 'successfully' do
            before { put "/cases/#{kase.id}", valid_params, auth(user) }
            it     { expect(response.status).to be_a_success_request }
            # it     { expect(parsed_body['case']).to match_hash(entity_of(kase.reload, display_type: 'full')) }

            it 'should has empty disabled steps' do
              expect(parsed_body['case']['disabled_steps']).to be_blank
            end
          end
        end
      end
    end

    context 'when update a case step' do
      let(:flow) do
        other_flow = create(:flow, initial: false, steps: [build(:step_type_form)])
        other_flow.publish(user)
        flow = create(:flow, initial: true, steps: [])
        create(:step_type_form_without_fields, flow: flow)
        flow.reload
        create(:field, step: flow.steps.first, title: 'user_age', field_type: 'integer')
        create(:field, step: flow.steps.first, title: 'inventory_items', field_type: 'inventory_item', category_inventory_id: [inventory_item.category.id], multiple: true)
        create(:field, step: flow.steps.first, title: 'size_of_tree',    field_type: 'inventory_field', origin_field_id: inventory_field_id)
        create(:step, flow: flow, child_flow: other_flow)
        flow.publish(user)
        flow.reload
      end
      let(:inventory_field_id) { inventory_item.category.fields.first.id }
      let!(:inventory_item)    { create(:inventory_item) }
      let(:inventory_value)    { '-123' }
      let(:fields) { flow.steps.first.fields.all }
      let(:valid_params) do
        { step_id: flow.steps.first.id,
         fields: [
           { id: fields.first.id,  value: '10' },
           { id: fields.second.id, value: [inventory_item.id] },
           { id: fields.third.id,  value: inventory_value }] }
      end
      let!(:kase) do
        case_params = { initial_flow_id: flow.id,
          fields: [{ id: fields.first.id, value: '1' }] }
        add_permision_to_user(user, flow.steps.pluck(:id))
        post '/cases', case_params, auth(user)
        Case.first
      end

      context 'no authentication' do
        before { put "/cases/#{kase.id}", valid_params }
        it     { expect(response.status).to be_an_unauthorized }
      end

      context 'with authentication' do
        context 'and user can\'t see the Step on Flow' do
          let(:error) { I18n.t(:permission_denied, action: I18n.t(:update), table_name: I18n.t(:case_steps)) }

          before { put "/cases/#{kase.id}", valid_params, auth(guest_user) }
          it     { expect(response.status).to be_a_forbidden }
          it     { expect(parsed_body).to be_an_error(error) }
        end

        context 'and user can execute first Step on Flow' do
          context 'and failure' do
            context 'because case not found' do
              before { put '/cases/123456789', valid_params, auth(user) }
              it     { expect(response.status).to be_a_not_found }
              it     { expect(parsed_body).to be_an_error('Couldn\'t find Case with \'id\'=123456789 [WHERE "cases"."status" != \'inactive\']') }
            end
          end

          context 'successfully' do
            let!(:inventory) { inventory_item.data.find_by(inventory_field_id: inventory_field_id) }
            before do
              add_permision_to_user(user, Step.pluck(:id))
              put "/cases/#{kase.id}", valid_params, auth(user)
            end
            it     { expect(response.status).to be_a_success_request }
            it     { expect(parsed_body['case']).to be_an_entity_of(kase.reload, display_type: 'full') }

            it 'case step data should be updated' do
              body_data = parsed_body['case']['current_step']['case_step_data_fields'].first['value']
              expect(body_data).to eql('10')
            end

            it 'should has empty disabled steps' do
              expect(parsed_body['case']['disabled_steps']).to be_blank
            end

            it 'should update field on Inventory' do
              expect(inventory.reload.content.to_f).to eql inventory_value.to_f
            end
          end
        end
      end
    end

    context 'when fill the last step and the first is unfilled and required' do
      let(:flow) do
        flow = create(:flow, initial: true, steps: [])
        create(:step_type_form_without_fields, flow: flow)
        create(:step_type_form, flow: flow)
        flow.reload
        create(:field, step: flow.steps.first, title: 'user_age', field_type: 'integer', requirements: { presence: true })
        flow.publish(user)
        flow.reload
      end
      let(:fields) { flow.steps.last.fields.all }
      let(:valid_params) do
        { step_id: flow.steps.last.id, fields: [{ id: fields.first.id, value: '10' }] }
      end
      let!(:kase) do
        add_permision_to_user(user, flow.steps.pluck(:id))
        case_params = { initial_flow_id: flow.id, step_id: flow.steps.last.id }
        post '/cases', case_params, auth(user)
        kase = Case.first
        kase.update disabled_steps: [flow.steps.first.id]
        kase
      end

      context 'no authentication' do
        before { put "/cases/#{kase.id}", valid_params }
        it     { expect(response.status).to be_an_unauthorized }
      end

      context 'with authentication' do
        context 'and user can\'t create the Step on Case' do
          let(:error) { I18n.t(:permission_denied, action: I18n.t(:create), table_name: I18n.t(:case_steps)) }

          before { put "/cases/#{kase.id}", valid_params, auth(guest_user) }
          it     { expect(response.status).to be_a_forbidden }
          it     { expect(parsed_body).to be_an_error(error) }
        end

        context 'and user can execute first Step on Flow' do
          context 'and failure' do
            context 'because case not found' do
              before { put '/cases/123456789', valid_params, auth(user) }
              it     { expect(response.status).to be_a_not_found }
              it     { expect(parsed_body).to be_an_error('Couldn\'t find Case with \'id\'=123456789 [WHERE "cases"."status" != \'inactive\']') }
            end
          end

          context 'successfully' do
            context 'when case already is not_satisfied and fill the required step' do
              let(:params_to_first_step) do
                { step_id: flow.steps.first.id,
                 fields: [{ id: flow.steps.first.fields.first.id, value: '1' }] }
              end

              before do
                kase.update! disabled_steps: []
                put "/cases/#{kase.id}", valid_params, auth(user)
                put "/cases/#{kase.id}", params_to_first_step, auth(user)
              end

              it { expect(response.status).to be_a_success_request }
              it { expect(parsed_body['case']).to be_an_entity_of(kase.reload, display_type: 'full') }
              it { expect(parsed_body['case']['status']).to eql 'finished' }
              it { expect(parsed_body['case']['steps_not_fulfilled']).to eql [] }

              # it 'case step data should be updated' do
              #   body_data = parsed_body['case']['current_step']['case_step_data_fields'].first['value']
              #   expect(body_data).to eql('10')
              # end
            end

            context 'when case already isn\'t not_satisfied' do
              before do
                kase.update! disabled_steps: []
                put "/cases/#{kase.id}", valid_params, auth(user)
              end

              it { expect(response.status).to be_a_success_request }
              # it { expect(parsed_body['case']).to be_an_entity_of(kase.reload, display_type: 'full') }
              it { expect(parsed_body['case']['status']).to eql 'not_satisfied' }
              it { expect(parsed_body['case']['steps_not_fulfilled']).to eql [flow.steps.first.id] }

              it 'case step data should be updated' do
                body_data = parsed_body['case']['current_step']['case_step_data_fields'].first['value']
                expect(body_data).to eql('10')
              end
            end
          end
        end
      end
    end

    context 'when case is finished (by trigger)' do
      let!(:flow) do
        other_flow = create(:flow, initial: false, steps: [build(:step_type_form)])
        other_flow.publish(user)
        flow = create(:flow, initial: true, steps: [])
        create(:resolution_state, flow: flow)
        step = create(:step_type_form_without_fields, flow: flow)
        create(:field, step: step, title: 'user_age', field_type: 'integer')
        create(:step, flow: flow, child_flow: other_flow)
        create(:trigger, step: step, action_type: 'finish_flow', action_values: [flow.resolution_states.first.id])
        flow.publish(user)
        flow.reload
      end
      let!(:resolution_state) { create(:resolution_state, flow: flow) }
      let(:fields) { flow.steps.first.fields.all }
      let(:valid_params) do
        { step_id: flow.steps.first.id, fields: [{ id: fields.first.id, value: '10' }] }
      end
      let!(:kase) do
        case_params = { initial_flow_id: flow.id, fields: [{ id: fields.first.id, value: '1' }] }
        add_permision_to_user(user, flow.steps.pluck(:id))
        post '/cases', case_params, auth(user)
        Case.first
      end

      context 'no authentication' do
        before { put "/cases/#{kase.id}", valid_params }
        it     { expect(response.status).to be_an_unauthorized }
      end

      context 'with authentication' do
        context 'and user can\'t see the Step on Flow' do
          let(:error) { I18n.t(:permission_denied, action: I18n.t(:update), table_name: I18n.t(:case_steps)) }

          before do
            kase.update status: 'active'
            put "/cases/#{kase.id}", valid_params, auth(guest_user)
          end

          it { expect(response.status).to be_a_forbidden }
          it { expect(parsed_body).to be_an_error(error) }
        end

        context 'and user can execute first Step on Flow' do
          context 'and failure' do
            context 'because case not found' do
              before { put '/cases/123456789', valid_params, auth(user) }
              it     { expect(response.status).to be_a_not_found }
              it     { expect(parsed_body).to be_an_error('Couldn\'t find Case with \'id\'=123456789 [WHERE "cases"."status" != \'inactive\']') }
            end

            context 'because case is finished' do
              before { put "/cases/#{kase.id}", valid_params, auth(user) }
              it     { expect(response.status).to be_a_not_allowed_method }
              it     { expect(parsed_body).to be_an_error(I18n.t(:case_is_finished)) }
            end
          end
        end
      end
    end
  end
end
