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

  describe 'to get Case history' do
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
      kase = Case.first
    end

    context 'no authentication' do
      before { get "/cases/#{kase.id}/history" }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t view the Case' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:show), table_name: I18n.t(:cases)) }

        before { get "/cases/#{kase.id}/history", {}, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can delete the Case' do
        context 'and failure' do
          context 'because case not found' do
            before { get '/cases/123456789/history', {}, auth(user) }
            it     { expect(response.status).to be_a_not_found }
            it     { expect(parsed_body).to be_an_error('Couldn\'t find Case with \'id\'=123456789') }
          end
        end

        context 'successfully' do
          context 'when not sent display_type full' do
            before { get "/cases/#{kase.id}/history", {}, auth(user) }
            it     { expect(response.status).to be_a_success_request }
            it     { expect(parsed_body['cases_log_entries']).to include_an_entity_of(kase.cases_log_entries.first) }
          end

          context 'when sent display_type full' do
            before { get "/cases/#{kase.id}/history", { display_type: 'full' }, auth(user) }
            it     { expect(response.status).to be_a_success_request }
            it     { expect(parsed_body['cases_log_entries']).to include_an_entity_of(kase.cases_log_entries.first, display_type: 'full') }
          end
        end
      end
    end
  end
end
