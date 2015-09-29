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

  describe 'on get case' do
    let!(:flow) do
      flow  = create(:flow, initial: true, steps: [build(:step_type_form_without_fields),
                                                   build(:step)])
      other_flow = create(:flow, initial: false, steps: [build(:step_type_form)])
      other_flow.publish(user)
      flow.steps.last.update! child_flow: other_flow
      field = create(:field, step: flow.steps.first, title: 'user_age', field_type: 'integer')
      create(:trigger, step: flow.steps.first, action_type: 'disable_steps',
             action_values: [other_flow.steps.first.id],
             trigger_conditions: [build(:trigger_condition, field: field)])
      flow.publish(user)
      flow.reload
    end
    let(:fields) { flow.steps.first.fields.all }
    let!(:kase) do
      add_permision_to_user(user, flow.steps.pluck(:id))
      case_params = { initial_flow_id: flow.id,
                     fields: [{ id: fields.first.id, value: '1' }] }
      post '/cases', case_params, auth(user)
      Case.first
    end

    context 'no authentication' do
      before { get "/cases/#{kase.id}" }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t see the Step on Flow' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:show), table_name: I18n.t(:cases)) }

        before { get "/cases/#{kase.id}", {}, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can execute first Step on Flow' do
        context 'and failure' do
          context 'because case not found' do
            before { get '/cases/123456789', {}, auth(user) }
            it     { expect(response.status).to be_a_not_found }
            it     { expect(parsed_body).to be_an_error('Couldn\'t find Case with \'id\'=123456789 [WHERE "cases"."status" != \'inactive\']') }
          end
        end

        context 'successfully' do
          context 'with display_type is full'do
            before do
              # set manage_flows=false to realy test Case permissions
              user.groups.first.permission.update(manage_flows: false)
              get "/cases/#{kase.id}", { display_type: 'full' }, auth(user)
            end

            it { expect(response.status).to be_a_success_request }
            it do
              expect(parsed_body['case']).to be_an_entity_of(kase, display_type: 'full', just_user_can_view: true, current_user: user)
            end

            it 'should has disabled steps' do
              expect(parsed_body['case']['disabled_steps']).to eql([Flow.last.steps.first.id])
            end
          end

          context 'with display_type isn\'t full'do
            before { get "/cases/#{kase.id}", {}, auth(user) }
            it     { expect(response.status).to be_a_success_request }
            it     { expect(parsed_body['case']).to be_an_entity_of(kase) }

            it 'should has disabled steps' do
              expect(parsed_body['case']['disabled_steps']).to eql([Flow.last.steps.first.id])
            end
          end
        end
      end
    end
  end
end
