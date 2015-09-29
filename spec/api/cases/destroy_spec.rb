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

  describe 'to inactive Case' do
    let(:flow) do
      flow = create(:flow, initial: true, steps: [])
      step = create(:step_type_form_without_fields, flow: flow)
      create(:field, step: step, title: 'user_age', field_type: 'integer')
      flow.publish(user)
      flow.reload
    end
    let!(:kase) do
      case_params = { initial_flow_id: flow.id,
                     fields: [{ id: flow.steps.first.fields.first.id, value: '1' }] }
      add_permision_to_user(user, flow.steps.pluck(:id))
      post '/cases', case_params, auth(user)
      Case.first
    end

    before { add_permision_to_user(user, flow.id, :flow_can_delete_own_cases) }

    context 'no authentication' do
      before { delete "/cases/#{kase.id}" }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t delete the Case' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:delete), table_name: I18n.t(:cases)) }

        before { delete "/cases/#{kase.id}", {}, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can delete the Case' do
        context 'and failure' do
          context 'because case not found' do
            before { delete '/cases/123456789', {}, auth(user) }
            it     { expect(response.status).to be_a_not_found }
            it     { expect(parsed_body).to be_an_error('Couldn\'t find Case with \'id\'=123456789 [WHERE "cases"."status" IN (\'active\', \'pending\', \'transfer\', \'not_satisfied\')]') }
          end
        end

        context 'successfully' do
          before { delete "/cases/#{kase.id}", {}, auth(user) }
          it     { expect(response.status).to be_a_success_request }
          it     { expect(parsed_body).to be_a_success_message_with(I18n.t(:case_deleted)) }

          it 'should Case status is inactive' do
            expect(kase.reload.status).to eql('inactive')
          end

          it 'should has a last log entries with action=delete_case' do
            expect(kase.cases_log_entries.last.action).to eql 'delete_case'
          end
        end
      end
    end
  end
end
