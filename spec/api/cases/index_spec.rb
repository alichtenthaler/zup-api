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

  describe 'to get all cases' do
    let(:other_user) { create(:user) }
    let(:other_flow) do
      flow = create(:flow, title: 'Other', initial: true, steps: [build(:step_type_form_without_fields), build(:step_type_form)])
      create(:field, step: flow.steps.first, title: 'company_age', field_type: 'integer')
      flow.publish(user)
      flow.reload
    end
    let(:flow) do
      flow = create(:flow, initial: true, steps: [build(:step_type_form_without_fields), build(:step_type_form)])
      create(:field, step: flow.steps.first, title: 'user_age', field_type: 'integer')
      flow.publish(user)
      flow.reload
    end
    let!(:kase1) do
      case_params = { initial_flow_id: flow.id, fields: [{ id: flow.steps.first.fields.first.id, value: '1' }] }
      add_permision_to_user(user, flow.steps.pluck(:id))
      post '/cases', case_params, auth(user)
      Case.last
    end
    let!(:kase2) do
      case_params = { initial_flow_id: other_flow.id, fields: [{ id: other_flow.steps.first.fields.first.id, value: '2' }] }
      add_permision_to_user(user, other_flow.steps.pluck(:id))
      post '/cases', case_params, auth(user)
      Case.last
    end
    let!(:kase3) do
      case_params = { initial_flow_id: flow.id, fields: [{ id: flow.steps.first.fields.first.id, value: '3' }] }
      add_permision_to_user(other_user, flow.steps.pluck(:id))
      post '/cases', case_params, auth(other_user)
      Case.last
    end

    before do
      user.groups.first.permission.update(manage_flows: false)
      other_user.groups.first.permission.update(manage_flows: false)
    end

    context 'no authentication' do
      before { get '/cases' }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'with filter by initial_flow_id' do
        let(:case_ids) { parsed_body['cases'].map { |k| k['id'] } }

        before { get '/cases', { initial_flow_id: flow.id.to_s }, auth(user) }
        it     { expect(response.status).to be_a_success_request }
        it     { expect(parsed_body['cases'].count).to eql 2 }
        it     { expect(case_ids).to include kase1.id }
        it     { expect(case_ids).to_not include kase2.id }
        it     { expect(case_ids).to include kase3.id }
      end

      context 'with filter by step_id' do
        let(:case_ids) { parsed_body['cases'].map { |k| k['id'] } }

        before { get '/cases', { step_id: other_flow.steps.first.id.to_s }, auth(user) }
        it     { expect(response.status).to be_a_success_request }
        it     { expect(parsed_body['cases'].count).to eql 1 }
        it     { expect(case_ids).to_not include kase1.id }
        it     { expect(case_ids).to include kase2.id }
        it     { expect(case_ids).to_not include kase3.id }
      end

      context 'with filter by responsible_group_id' do
        let(:case_ids) { parsed_body['cases'].map { |k| k['id'] } }

        before do
          add_permision_to_user(user, kase1.case_steps.first.step.id)
          put "/cases/#{kase1.id}/case_steps/#{kase1.case_steps.first.id}", { responsible_group_id: user.groups.first.id }, auth(user)
          get '/cases', { responsible_group_id: user.groups.first.id.to_s }, auth(user)
        end

        it { expect(response.status).to be_a_success_request }
        it { expect(parsed_body['cases'].count).to eql 1 }
        it { expect(case_ids).to include kase1.id }
        it { expect(case_ids).to_not include kase2.id }
        it { expect(case_ids).to_not include kase3.id }
      end

      context 'with filter by responsible_user_id' do
        let(:case_ids) { parsed_body['cases'].map { |k| k['id'] } }

        before do
          add_permision_to_user(user, kase1.case_steps.first.step.id)
          put "/cases/#{kase1.id}/case_steps/#{kase1.case_steps.first.id}", { responsible_user_id: user.id + 1 }, auth(user)
          get '/cases', { responsible_user_id: user.id.to_s }, auth(user)
        end

        it { expect(response.status).to be_a_success_request }
        it { expect(parsed_body['cases'].count).to eql 1 }
        it { expect(case_ids).to_not include kase1.id }
        it { expect(case_ids).to include kase2.id }
        it { expect(case_ids).to_not include kase3.id }
      end

      context 'with filter by created_by_id' do
        let(:case_ids) { parsed_body['cases'].map { |k| k['id'] } }

        before { get '/cases', { created_by_id: user.id.to_s }, auth(user) }
        it     { expect(response.status).to be_a_success_request }
        it     { expect(parsed_body['cases'].count).to eql 2 }
        it     { expect(case_ids).to include kase1.id }
        it     { expect(case_ids).to include kase2.id }
        it     { expect(case_ids).to_not include kase3.id }
      end

      context 'with filter by updated_by_id' do
        let(:case_ids) { parsed_body['cases'].map { |k| k['id'] } }

        before do
          add_permision_to_user(user, kase1.case_steps.first.step.id)
          put "/cases/#{kase1.id}/case_steps/#{kase1.case_steps.first.id}", { responsible_user_id: user.id }, auth(user)
          get '/cases', { updated_by_id: user.id.to_s }, auth(user)
        end

        it { expect(response.status).to be_a_success_request }
        it { expect(parsed_body['cases'].count).to eql 1 }
        it { expect(case_ids).to include kase1.id }
        it { expect(case_ids).to_not include kase2.id }
        it { expect(case_ids).to_not include kase3.id }
      end

      context 'with filter by completed' do
        let(:case_ids) { parsed_body['cases'].map { |k| k['id'] } }

        before do
          create(:resolution_state, flow: kase1.initial_flow)
          add_permision_to_user(user, kase1.case_steps.first.step.id)
          put "/cases/#{kase1.id}/finish", { resolution_state_id: kase1.initial_flow.resolution_states.first.id }, auth(user)
          get '/cases', { completed: true }, auth(user)
        end

        it { expect(response.status).to be_a_success_request }
        it { expect(parsed_body['cases'].count).to eql 1 }
        it { expect(case_ids).to include kase1.id }
        it { expect(case_ids).to_not include kase2.id }
        it { expect(case_ids).to_not include kase3.id }
      end

      context 'without filter' do
        context 'when user can see all items' do
          context 'when not use display_type full' do
            before { get '/cases', {}, auth(user) }
            it     { expect(response.status).to be_a_success_request }
            it     { expect(parsed_body['cases'].count).to eql 3 }
            it     { expect(parsed_body['cases']).to include_an_entity_of(kase1, just_user_can_view: true, current_user: user) }
            it     { expect(parsed_body['cases']).to include_an_entity_of(kase2, just_user_can_view: true, current_user: user) }
            it     { expect(parsed_body['cases']).to include_an_entity_of(kase3, just_user_can_view: true, current_user: user) }

            it 'should see only the cases_step ids' do
              kase = parsed_body['cases'].first
              expect(kase['case_step_ids']).to be_present
            end
          end

          context 'when use display_type full' do
            before { get '/cases', { display_type: 'full' }, auth(user) }
            it     { expect(response.status).to be_a_success_request }
            it     { expect(parsed_body['cases'].count).to eql 3 }
            it     { expect(parsed_body['cases']).to include_an_entity_of(kase1, display_type: 'full', just_user_can_view: true, current_user: user) }
            it     { expect(parsed_body['cases']).to include_an_entity_of(kase2, display_type: 'full', just_user_can_view: true, current_user: user) }
            it     { expect(parsed_body['cases']).to include_an_entity_of(kase3, display_type: 'full', just_user_can_view: true, current_user: user) }

            it 'should see the cases_step objects' do
              kase = parsed_body['cases'].first
              expect(kase['case_step_ids']).to be_present
              expect(kase['current_step']).to be_present
            end
          end

          context 'when use paginate 1 by page' do
            context 'in page 1' do
              before { get '/cases', { page: 1, per_page: 1 }, auth(user) }
              it     { expect(response.status).to be_a_success_request }
              it     { expect(parsed_body['cases'].count).to eql 1 }
              # it     { expect(parsed_body['cases']).to include_an_entity_of(kase1, just_user_can_view: true, current_user: user) }
              it     { expect(parsed_body['cases']).to_not include_an_entity_of(kase2, just_user_can_view: true, current_user: user) }
              it     { expect(parsed_body['cases']).to_not include_an_entity_of(kase3, just_user_can_view: true, current_user: user) }
            end

            context 'in page 2' do
              before { get '/cases', { page: 2, per_page: 1 }, auth(user) }
              it     { expect(response.status).to be_a_success_request }
              it     { expect(parsed_body['cases'].count).to eql 1 }
              it     { expect(parsed_body['cases']).to_not include_an_entity_of(kase1, just_user_can_view: true, current_user: user) }
              it     { expect(parsed_body['cases']).to include_an_entity_of(kase2, just_user_can_view: true, current_user: user) }
              it     { expect(parsed_body['cases']).to_not include_an_entity_of(kase3, just_user_can_view: true, current_user: user) }
            end
          end
        end
      end
    end
  end
end
