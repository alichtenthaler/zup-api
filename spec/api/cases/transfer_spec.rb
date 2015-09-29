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

  describe 'to transfer Case' do
    let(:flow) do
      flow = create(:flow, initial: true, steps: [])
      step = create(:step_type_form_without_fields, flow: flow)
      create(:field, step: step, title: 'user_age', field_type: 'integer')
      flow.publish(user)
      flow.reload
    end
    let(:other_flow) do
      flow = create(:flow, steps: [build(:step_type_form)])
      flow.publish(user)
      flow.reload
    end
    let(:fields) { flow.steps.first.fields.all }
    let(:valid_params) do
      { step_id: flow.steps.first.id, fields: [{ id: fields.first.id, value: '10' }] }
    end
    let!(:kase) do
      case_params = { initial_flow_id: flow.id,
                     fields: [{ id: fields.first.id, value: '1' }] }
      add_permision_to_user(user, flow.steps.pluck(:id))
      post '/cases', case_params, auth(user)
      Case.first
    end

    context 'no authentication' do
      before { put "/cases/#{kase.id}/transfer", flow_id: other_flow.id }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t update the Case' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:update), table_name: I18n.t(:cases)) }

        before { put "/cases/#{kase.id}/transfer", { flow_id: other_flow.id }, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can update the Case' do
        context 'and failure' do
          context 'because case not found' do
            before { put '/cases/123456789/transfer', { flow_id: other_flow.id }, auth(user) }
            it     { expect(response.status).to be_a_not_found }
            it     { expect(parsed_body).to be_an_error('Couldn\'t find Case with \'id\'=123456789 [WHERE "cases"."status" != \'inactive\']') }
          end
        end

        context 'successfully' do
          let(:new_kase) { Case.find_by(original_case_id: kase.id) }

          before { put "/cases/#{kase.id}/transfer", { flow_id: other_flow.id }, auth(user) }
          it     { expect(response.status).to be_a_success_request }
          it     { expect(parsed_body).to be_a_success_message_with(I18n.t(:case_updated)) }
          it     { expect(parsed_body['case']).to be_an_entity_of(new_kase) }
          it     { expect(parsed_body['case']['original_case_id']).to eql(kase.id) }

          it 'should old Case status is transfer' do
            expect(kase.reload.status).to eql('transfer')
          end

          it 'should has old log entries' do
            expect(kase.cases_log_entries.count).to eql 2
          end

          it 'should new Case status is active' do
            expect(new_kase.reload.status).to eql('active')
          end

          it 'should has new log entries' do
            expect(new_kase.cases_log_entries.count).to eql 1
          end
        end
      end
    end
  end
end
