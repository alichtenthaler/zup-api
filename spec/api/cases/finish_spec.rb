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

  describe 'to finish' do
    context 'when have one step filled' do
      let(:flow) do
        other_flow = create(:flow, initial: false, steps: [build(:step_type_form)])
        other_flow.publish(user)
        flow = create(:flow, initial: true, steps: [])
        step = create(:step_type_form_without_fields, flow: flow)
        create(:field, step: step, title: 'user_age', field_type: 'integer')
        create(:step, flow: flow, child_flow: other_flow)
        flow.publish(user)
        flow.reload
      end
      let(:fields) { flow.steps.first.fields.all }
      let(:valid_params) do
        { step_id: flow.steps.first.id,
         fields: [{ id: fields.first.id, value: '10' }] }
      end
      let!(:kase) do
        case_params = { initial_flow_id: flow.id,
          fields: [{ id: fields.first.id, value: '1' }] }
        add_permision_to_user(user, flow.steps.pluck(:id))
        post '/cases', case_params, auth(user)
        Case.first
      end

      context 'no authentication' do
        before { put "/cases/#{kase.id}/finish", resolution_state_id: 123 }
        it     { expect(response.status).to be_an_unauthorized }
      end

      context 'with authentication' do
        context 'and user can\'t update the Case' do
          let(:error) { I18n.t(:permission_denied, action: I18n.t(:update), table_name: I18n.t(:cases)) }

          before { put "/cases/#{kase.id}/finish", { resolution_state_id: 123 }, auth(guest_user) }
          it     { expect(response.status).to be_a_forbidden }
          it     { expect(parsed_body).to be_an_error(error) }
        end

        context 'and user can execute first Step on Flow' do
          context 'and failure' do
            context 'because case not found' do
              before { put '/cases/123456789/finish', { resolution_state_id: 123 }, auth(user) }
              it     { expect(response.status).to be_a_not_found }
            end
          end

          context 'successfully' do
            context 'when Case is already finished' do
              before do
                resolution_state = create(:resolution_state, flow: flow)
                kase.update(status: 'finished', resolution_state_id: flow.resolution_states.first.id)
                put "/cases/#{kase.id}/finish", { resolution_state_id: 123 }, auth(user)
              end

              it { expect(response.status).to be_a_success_request }
              it { expect(parsed_body).to be_a_success_message_with(I18n.t(:case_is_already_finished)) }

              it 'should Case status is finished' do
                expect(kase.reload.status).to eql('finished')
              end
            end

            context 'when Case isn\'t finished' do
              before do
                create(:resolution_state, flow: flow)
                put "/cases/#{kase.id}/finish", { resolution_state_id: flow.resolution_states.first.id }, auth(user)
              end
              it     { expect(response.status).to be_a_success_request }
              it     { expect(parsed_body).to be_a_success_message_with(I18n.t(:finished_case)) }

              it 'should Case status is finished' do
                expect(kase.reload.status).to eql('finished')
              end
            end
          end
        end
      end
    end
  end
end
