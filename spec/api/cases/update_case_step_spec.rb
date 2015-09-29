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

  describe 'to update CaseStep' do
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
      before { put "/cases/#{kase.id}/case_steps/#{kase.case_steps.last.id}" }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t update the Case' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:update), table_name: I18n.t(:case_steps)) }

        before { put "/cases/#{kase.id}/case_steps/#{kase.case_steps.last.id}", {}, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can update the Case' do
        context 'and failure' do
          context 'because case not found' do
            before { put "/cases/#{kase.id}/case_steps/123456789", {}, auth(user) }
            it     { expect(response.status).to be_a_not_found }
            it     { expect(parsed_body).to be_an_error('Couldn\'t find CaseStep with \'id\'=123456789') }
          end
        end

        context 'successfully' do
          context 'when set responsible_user_id' do
            before { put "/cases/#{kase.id}/case_steps/#{kase.case_steps.last.id}", { responsible_user_id: nil }, auth(user) }
            it     { expect(response.status).to be_a_success_request }
            it     { expect(parsed_body).to be_a_success_message_with(I18n.t(:case_step_updated)) }

            it 'should responsible_user_id be blank' do
              expect(kase.case_steps.last.responsible_user_id).to be_blank
            end

            it 'should has log entries' do
              expect(kase.cases_log_entries.count).to eql 2
            end
          end

          context 'when set responsible_user_id and responsible_group_id' do
            let(:valid_params1) { { responsible_user_id: nil, responsible_group_id: user.groups.first.id } }

            before { put "/cases/#{kase.id}/case_steps/#{kase.case_steps.last.id}", valid_params1, auth(user) }
            it     { expect(response.status).to be_a_success_request }
            it     { expect(parsed_body).to be_a_success_message_with(I18n.t(:case_step_updated)) }

            it 'should responsible_user_id be blank' do
              expect(kase.case_steps.last.responsible_user_id).to eql(valid_params1[:responsible_user_id])
            end

            it 'should responsible_group_id be group id' do
              expect(kase.case_steps.last.responsible_group_id).to eql(valid_params1[:responsible_group_id])
            end

            it 'should has log entries' do
              expect(kase.cases_log_entries.count).to eql 2
            end
          end
        end
      end
    end
  end
end
