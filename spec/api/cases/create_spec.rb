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

  describe 'on create' do
    context 'default test' do
      let(:flow) do
        flow = create(:flow, initial: true, steps: [build(:step_type_form_without_fields)])
        create(:field, step: flow.steps.first, title: 'user_age', field_type: 'integer', requirements: { presence: true, minimum: 1, maximum: 150 })
        create(:field, step: flow.steps.first, title: 'user_cpf', field_type: 'cpf')
        create(:field, step: flow.steps.first, title: 'user_email', field_type: 'email')
        create(:field, step: flow.steps.first, title: 'user_photo', field_type: 'image')
        create(:field, step: flow.steps.first, title: 'user_att', field_type: 'attachment', filter: 'jpg,png,txt')
        create(:field, step: flow.steps.first, title: 'inventory_items', field_type: 'inventory_item', category_inventory_id: [inventory_item.category.id], multiple: true)
        create(:field, step: flow.steps.first, title: 'size_of_tree', field_type: 'inventory_field', origin_field_id: inventory_field_id)
        create(:field, step: flow.steps.first, title: 'Services', field_type: 'checkbox', values: ['Option 1', 'Option 2'])
        create(:field, step: flow.steps.first, title: 'Newsletter', field_type: 'radio', values: ['Yes', 'No'], requirements: { presence: true })
        create(:field, step: flow.steps.first, title: 'Country', field_type: 'select', values: ['Brazil', 'USA'])
        flow.publish(user)
        flow.the_version
      end
      let(:inventory_field_id) { inventory_item.category.fields.first.id }
      let(:inventory_item)     { create(:inventory_item) }
      let(:fields)             { flow.my_steps.first.my_fields }
      let(:invalid_params) do
        { initial_flow_id: flow.id,
         fields: [
           { id: fields.first.id,  value: 'invalid' },
           { id: fields.second.id, value: '' },
           { id: fields.third.id,  value: 'invalid' }]
        }
      end
      let(:inventory_value) { '123' }
      let(:valid_params) do
        { initial_flow_id: flow.id,
         fields: [
           { id: fields[0].id, value: '18' },
           { id: fields[1].id, value: '146.832.574-40' },
           { id: fields[2].id, value: 'chapolim@chaves.com' },
           { id: fields[3].id, value: [
             { file_name: 'valid_report_item_photo.jpg',
              content: Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg").read) },
             { file_name: 'valid_report_item_photo2.jpg',
              content: Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg").read) }
           ] },
           { id: fields[4].id, value: [
             {
               file_name: 'valid_report_item_attachement.jpg',
               content: Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg").read)
             }
           ] },
           { id: fields[5].id, value: [inventory_item.id] },
           { id: fields[6].id, value: inventory_value },
           { id: fields[7].id, value: ['Option 2'] },
           { id: fields[8].id, value: 'No' },
           { id: fields[9].id, value: ['USA', 'Brazil'] }]
        }
      end

      before { add_permision_to_user(user, flow.steps.first.id) }

      context 'no authentication' do
        before { post '/cases', valid_params }
        it     { expect(response.status).to be_an_unauthorized }
      end

      context 'with authentication' do
        context 'and user can\'t execute first Step on Flow' do
          let(:error) { I18n.t(:permission_denied, action: I18n.t(:create), table_name: I18n.t(:case_steps)) }

          before { post '/cases', valid_params, auth(guest_user) }
          it     { expect(response.status).to be_a_forbidden }
          it     { expect(parsed_body).to be_an_error(error) }
        end

        context 'and user can execute first Step on Flow' do
          context 'and failure' do
            context 'because validations fields' do
              let(:errors) do
                { 'case_steps.fields' => [
                  "user_age #{I18n.t("errors.messages.greater_than", count: 1)}",
                  "user_email #{I18n.t("errors.messages.invalid")}",
                  "Newsletter #{I18n.t("errors.messages.blank")}"
                ] }
              end

              before { post '/cases', invalid_params, auth(user) }
              it     { expect(response.status).to be_a_bad_request }
              it     { expect(parsed_body).to be_an_error(errors) }
            end
          end

          context 'successfully' do
            let(:kase)       { Case.last }
            let(:inventory)  { inventory_item.data.find_by(inventory_field_id: inventory_field_id) }

            before { post '/cases', valid_params, auth(user) }

            it { expect(response.status).to be_a_requisition_created }
            it { expect(parsed_body).to be_a_success_message_with(I18n.t(:case_created)) }
            it { expect(parsed_body['case']).to be_an_entity_of(kase, display_type: 'full') }

            it 'creates a CasesLogEntry for the Case with correct values' do
              cases_log_entry = kase.cases_log_entries.first

              expect(cases_log_entry.action).to eq('create_case')
              expect(cases_log_entry.user_id).to eq(user.id)
              expect(cases_log_entry.flow_id).to eq(flow.id)
              expect(cases_log_entry.flow_version).to_not be_nil
              expect(cases_log_entry.step_id).to_not be_nil
            end

            it 'should update field on Inventory' do
              expect(inventory.reload.content.to_f).to eql inventory_value.to_f
            end
          end
        end
      end
    end

    context 'when step type is flow' do
      let(:flow) do
        flow = create(:flow, initial: true, steps: [build(:step_type_form_without_fields)])
        create(:field, step: flow.steps.first, title: 'user_age', field_type: 'integer', requirements: { presence: true, minimum: 1, maximum: 150 })
        create(:field, step: flow.steps.first, title: 'user_email', field_type: 'email')
        flow.publish(user)
        flow.the_version
      end
      let(:fields) { flow.my_steps.first.my_fields }
      let(:valid_params) do
        { initial_flow_id: flow.id,
         fields: [
           { id: fields.first.id,  value: '18' },
           { id: fields.second.id, value: 'chapolim@chaves.com' }] }
      end
      let(:kase) { Case.last }

      before do
        add_permision_to_user(user, flow.steps.first.id)
        post '/cases', valid_params, auth(user)
      end

      it { expect(response.status).to be_a_requisition_created }
      it { expect(parsed_body).to be_a_success_message_with(I18n.t(:case_created)) }
      it { expect(parsed_body['case']).to be_an_entity_of(kase, display_type: 'full') }

      it 'creates a CasesLogEntry for the Case with correct values' do
        cases_log_entry = kase.cases_log_entries.first

        expect(cases_log_entry.action).to eq('create_case')
        expect(cases_log_entry.user_id).to eq(user.id)
        expect(cases_log_entry.flow_id).to eq(flow.id)
        expect(cases_log_entry.flow_version).to_not be_nil
        expect(cases_log_entry.step_id).to_not be_nil
      end

      context 'when remove a field of step' do
        before do
          @field = flow.steps.first.fields.last
          delete "/flows/#{flow.id}/steps/#{@field.step.id}/fields/#{@field.id}", {}, auth(user)
          post "/flows/#{flow.id}/publish", {}, auth(user)
        end

        it 'should be active is false' do
          expect(@field.reload.active).to eql(false)
        end

        it 'should be create a version for initial flow' do
          expect(flow.versions.count).to eql 2
        end

        it 'should be create a version for step' do
          expect(flow.steps.first.versions.count).to eql 2
        end

        it 'should NOT be create a version for other field' do
          expect(@field.step.fields.first.versions.count).to eql 1
        end
      end

      context 'when add more one field to step' do
        before do
          @step = flow.steps.first
          post "/flows/#{flow.id}/steps/#{@step.id}/fields", { title: 'x', field_type:'integer' }, auth(user)
          post "/flows/#{flow.id}/publish", {}, auth(user)
        end

        it 'should has 3 fields' do
          expect(@step.fields.count).to eql 3
        end

        it 'should be create a version for initial flow' do
          expect(flow.versions.count).to eql 2
        end

        it 'should be create a version for step' do
          expect(flow.steps.first.versions.count).to eql 2
        end

        it 'should NOT be create a version for all fields (because others have no changes)' do
          expect(@step.fields.to_a.sum { |f| f.versions.count }).to eql 3
        end
      end
    end

    context 'when step have a trigger to disable other step' do
      let(:flow) do
        flow = create(:flow, initial: true, steps: [build(:step_type_form_without_fields), build(:step_type_form_without_fields)])
        create(:field, step: flow.steps.first, title: 'user_age',        field_type: 'integer')
        create(:field, step: flow.steps.first, title: 'inventory_items', field_type: 'inventory_item', category_inventory_id: [inventory_item.category.id], multiple: true)
        create(:field, step: flow.steps.first, title: 'size_of_tree',    field_type: 'inventory_field', origin_field_id: inventory_field_id)
        flow.steps.first.triggers << build(:trigger, action_type: 'disable_steps', action_values: [flow.steps.first.fields.reload.first.step.id])
        flow.publish(user)
        flow.reload
      end
      let(:inventory_field_id) { inventory_item.category.fields.first.id }
      let(:inventory_item)     { create(:inventory_item) }
      let(:kase)               { Case.last }
      let(:valid_params) do
        {
          initial_flow_id: flow.id,
          fields: [
            { id: flow.steps.first.fields.first.id, value: '1' },
            { id: flow.steps.first.fields.last.id, value: '1' }
          ]
        }
      end

      before do
        add_permision_to_user(user, flow.steps.pluck(:id))
        post '/cases', valid_params, auth(user)
      end

      it { expect(response.status).to be_a_requisition_created }
      it { expect(parsed_body).to be_a_success_message_with(I18n.t(:case_created)) }
      it { expect(parsed_body['case']).to be_an_entity_of(kase, display_type: 'full') }

      it 'creates a CasesLogEntry for the Case with correct values' do
        cases_log_entry = kase.cases_log_entries.first

        expect(cases_log_entry.action).to eq('create_case')
        expect(cases_log_entry.user_id).to eq(user.id)
        expect(cases_log_entry.flow_id).to eq(flow.id)
        expect(cases_log_entry.flow_version).to_not be_nil
        expect(cases_log_entry.step_id).to_not be_nil
      end

      it 'should set the status with finished' do
        expect(kase.status).to eql 'active'
      end

      it 'should set the called trigger on CaseStep' do
        trigger = Trigger.find_by(action_type: 'disable_steps')
        expect(kase.case_steps.first.trigger_ids.first).to eql(trigger.id)
      end
    end

    context 'when step have a trigger to finish Case' do
      let(:flow) do
        flow = create(:flow, :with_resolution_state, initial: true, steps: [build(:step_type_form_without_fields), build(:step_type_form_without_fields)])
        create(:field, step: flow.steps.first, title: 'user_age', field_type: 'integer')
        flow.steps.first.triggers << build(:trigger, action_type: 'finish_flow', action_values: [flow.resolution_states.first.id])
        flow.publish(user)
        flow.reload
      end
      let(:kase)   { Case.last }
      let(:valid_params) do
        { initial_flow_id: flow.id,
         fields: [{ id: flow.steps.first.fields.first.id, value: '1' }] }
      end

      before do
        add_permision_to_user(user, flow.steps.pluck(:id))
        post '/cases', valid_params, auth(user)
      end

      it { expect(response.status).to be_a_requisition_created }
      it { expect(parsed_body).to be_a_success_message_with(I18n.t(:case_created)) }
      it { expect(parsed_body['case']).to be_an_entity_of(kase, display_type: 'full') }

      it 'should has 3 log entries' do
        expect(kase.cases_log_entries.count).to eql 3
      end

      it 'should set the status with finished' do
        expect(kase.status).to eql 'finished'
      end

      it 'should set the called trigger on CaseStep' do
        trigger = Trigger.find_by(action_type: 'finish_flow')
        expect(kase.case_steps.first.trigger_ids.first).to eql(trigger.id)
      end
    end

    context 'when step have a trigger to transfer Issey Miyakeflow' do
      let(:flow) do
        flow  = create(:flow, initial: true, steps: [build(:step_type_form_without_fields)])
        field = create(:field, step: flow.steps.first, title: 'user_age', field_type: 'integer')
        other_flow = create(:flow, initial: false, steps: [build(:step_type_form)])
        other_flow.publish(user)
        flow.steps.first.triggers << build(:trigger, action_type: 'transfer_flow', action_values: [other_flow.id],
                                           trigger_conditions: [build(:trigger_condition, field: field)])
        flow.publish(user)
        flow.reload
      end
      let(:kase)   { Case.last }
      let(:valid_params) do
        { initial_flow_id: flow.id,
         fields: [{ id: flow.steps.first.fields.first.id, value: '1' }] }
      end

      before do
        add_permision_to_user(user, flow.steps.pluck(:id))
        post '/cases', valid_params, auth(user)
      end

      it { expect(response.status).to be_a_requisition_created }
      it { expect(parsed_body).to be_a_success_message_with(I18n.t(:case_created)) }
      it { expect(parsed_body['case']).to be_an_entity_of(kase, display_type: 'full') }

      it 'should has 2 log entries' do
        expect(kase.cases_log_entries.count).to eql 2
      end

      it 'should set the status with finished' do
        expect(kase.status).to eql 'active'
      end

      it 'should set the called trigger on CaseStep' do
        trigger = Trigger.find_by(action_type: 'transfer_flow')
        expect(kase.case_steps.first.trigger_ids).to include trigger.id
      end
    end
  end
end
