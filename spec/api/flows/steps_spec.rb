require 'rails_helper'

describe Flows::Steps::API do
  let(:user)       { create(:user) }
  let(:guest_user) { create(:guest_user) }

  describe 'on create' do
    let!(:flow)        { create(:flow_without_steps) }
    let(:valid_params) { { title: 'Success', step_type: :flow } }

    context 'no authentication' do
      before { post "/flows/#{flow.id}/steps", valid_params }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage steps' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:create), table_name: I18n.t(:steps)) }

        before { post "/flows/#{flow.id}/steps", valid_params, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can manage steps' do
        context 'and failure' do
          context 'because validations fields' do
            before { post "/flows/#{flow.id}/steps", {}, auth(user) }

            it { expect(response.status).to be_a_bad_request }
            it { expect(response.body).to be_an_error('title' => [I18n.t('activerecord.errors.messages.blank')]) }
          end

          context 'because step type isn\'t flow or form' do
            before { post "/flows/#{flow.id}/steps", valid_params.merge(step_type: :invalid), auth(user) }

            it { expect(response.status).to be_a_bad_request }
            it { expect(response.body).to be_an_error('step_type' => [I18n.t('activerecord.errors.messages.inclusion')]) }
          end
        end

        context 'successfully' do
          context 'when type is flow' do
            let(:title) { valid_params.delete(:title) }
            let(:step)  { flow.reload.steps.find_by(title: title) }
            before { post "/flows/#{flow.id}/steps", valid_params, auth(user) }

            it { expect(response.status).to be_a_requisition_created }
            it { expect(response.body).to be_a_success_message_with(I18n.t(:step_created)) }
            it { expect(parsed_body['step']).to be_an_entity_of(step, display_type: 'full') }

            it 'should update steps_versions on flow' do
              expect(step.flow.steps_versions).to eql(step.id.to_s => nil)
            end
           end

          context 'when type is form' do
            let(:title) { valid_params.delete(:title) }
            let(:step)  { flow.reload.steps.find_by(title: title) }
            before { post "/flows/#{flow.id}/steps", valid_params.merge(step_type: :form), auth(user) }

            it { expect(response.status).to be_a_requisition_created }
            it { expect(response.body).to be_a_success_message_with(I18n.t(:step_created)) }
            it { expect(parsed_body['step']).to be_an_entity_of(step, display_type: 'full') }

            it 'should update steps_versions on flow' do
              expect(step.flow.steps_versions).to eql(step.id.to_s => nil)
            end
          end
        end
      end
    end
  end

  describe 'on update' do
    let(:flow)         { create(:flow) }
    let!(:step)        { flow.steps.first }
    let(:valid_params) { { title: 'New Title' } }

    context 'no authentication' do
      before { put "/flows/#{flow.id}/steps/#{step.id}", valid_params }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage steps' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:update), table_name: I18n.t(:steps)) }

        before { put "/flows/#{flow.id}/steps/#{step.id}", valid_params, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can manage steps' do
        context 'and failure' do
          context 'because validations fields' do
            before { put "/flows/#{flow.id}/steps/#{step.id}", {}, auth(user) }

            it { expect(response.status).to be_a_bad_request }
            it { expect(response.body).to be_an_error('title' => [I18n.t('activerecord.errors.messages.blank')]) }
          end

          context 'because step type isn\'t flow or form' do
            before { put "/flows/#{flow.id}/steps/#{step.id}", valid_params.merge(step_type: :invalid), auth(user) }

            it { expect(response.status).to be_a_bad_request }
            it { expect(response.body).to be_an_error('step_type' => [I18n.t('activerecord.errors.messages.inclusion')]) }
          end

          context 'because not found' do
            before { put "/flows/#{flow.id}/steps/12345678", valid_params, auth(user) }

            it { expect(response.status).to be_a_not_found }
            it { expect(response.body).to be_an_error('Couldn\'t find Step with \'id\'=12345678 [WHERE "steps"."flow_id" = $1]') }
          end
        end

        context 'successfully' do
          before { put "/flows/#{flow.id}/steps/#{step.id}", valid_params, auth(user) }

          it { expect(response.status).to be_a_success_request }
          it { expect(response.body).to be_a_success_message_with(I18n.t(:step_updated)) }
        end
      end
    end
  end

  describe 'on delete' do
    let(:flow)  { create(:flow) }
    let!(:step) { flow.steps.first }

    context 'no authentication' do
      before { delete "/flows/#{flow.id}/steps/#{step.id}" }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage steps' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:delete), table_name: I18n.t(:steps)) }

        before { delete "/flows/#{flow.id}/steps/#{step.id}", {}, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can manage steps' do
        context 'and failure' do
          context 'because not found' do
            before { delete "/flows/#{flow.id}/steps/123456789", {}, auth(user) }

            it { expect(response.status).to be_a_not_found }
            it { expect(response.body).to be_an_error('Couldn\'t find Step with \'id\'=123456789 [WHERE "steps"."flow_id" = $1]') }
          end
        end

        context 'successfully' do
          before { delete "/flows/#{flow.id}/steps/#{step.id}", {}, auth(user) }

          it { expect(response.status).to be_a_success_request }
          it { expect(response.body).to be_a_success_message_with(I18n.t(:step_deleted)) }
        end
      end
    end
  end

  describe 'on list' do
    let(:flow)  { create(:flow) }
    let!(:step) { flow.steps.first }

    context 'no authentication' do
      before { get "/flows/#{flow.id}/steps" }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage steps' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:view), table_name: I18n.t(:steps)) }

        before { get "/flows/#{flow.id}/steps", {}, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can manage steps' do
        context 'when sent display_type full' do
          before { get "/flows/#{flow.id}/steps", { display_type: 'full' }, auth(user) }

          it { expect(response.status).to be_a_success_request }
          it { expect(parsed_body['steps']).to include_an_entity_of(step, display_type: 'full') }
        end

        context 'when not sent display_type full' do
          before { get "/flows/#{flow.id}/steps", {}, auth(user) }

          it { expect(response.status).to be_a_success_request }
          it { expect(parsed_body['steps']).to include_an_entity_of(step) }
        end
      end
    end
  end

  describe 'on show' do
    let!(:flow) { create(:flow) }
    let(:step)  { flow.steps.first }

    context 'no authentication' do
      before { get "/flows/#{flow.id}/steps/#{step.id}" }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage steps' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:view), table_name: I18n.t(:steps)) }

        before { get "/flows/#{flow.id}/steps/#{step.id}", {}, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can manage steps' do
        context 'and failure' do
          context 'because not found' do
            before { get "/flows/#{flow.id}/steps/12345678", {}, auth(user) }

            it { expect(response.status).to be_a_not_found }
            it { expect(response.body).to be_an_error('Couldn\'t find Step with \'id\'=12345678 [WHERE "steps"."flow_id" = $1]') }
          end
        end

        context 'successfully' do
          before { get "/flows/#{flow.id}/steps/#{step.id}", {}, auth(user) }

          it { expect(response.status).to be_a_success_request }
          it { expect(parsed_body['step']).to be_an_entity_of(step) }
        end
      end
    end
  end

  describe 'on sort' do
    let!(:flow)        { create(:flow_with_more_steps) }
    let(:step)         { flow.steps.first }
    let(:other_step)   { flow.steps.second }
    let(:valid_params) { { ids: [other_step.id, step.id] } }

    context 'no authentication' do
      before { put "/flows/#{flow.id}/steps", valid_params }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage steps' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:update), table_name: I18n.t(:steps)) }

        before { put "/flows/#{flow.id}/steps", valid_params, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can manage steps' do
        context 'and failure' do
          context 'because not found' do
            before { put "/flows/#{flow.id}/steps", { ids:[123456789] }, auth(user) }

            it { expect(response.status).to be_a_not_found }
            it { expect(response.body).to be_an_error('Couldn\'t find Step with \'id\'=123456789 [WHERE "steps"."flow_id" = $1]') }
          end
        end

        context 'successfully' do
          let(:reload_flow) { flow.reload }
          let(:steps_ids)   { reload_flow.steps.pluck(:id).map(&:to_s) }

          before { put "/flows/#{flow.id}/steps", valid_params, auth(user) }

          it { expect(response.status).to be_a_success_request }
          it { expect(response.body).to be_a_success_message_with(I18n.t(:steps_order_updated)) }

          it 'should has steps_versions on flow' do
            expect(reload_flow.steps_versions).to eql(steps_ids.first => nil, steps_ids.last => nil)
          end
        end
      end
    end
  end

  describe 'PUT permissions' do
    let(:valid_params) { { group_ids: [user.groups.first.id], permission_type: 'can_view_step' } }
    let!(:flow)        { create(:flow) }
    let(:step)         { flow.steps.first }

    context 'no authentication' do
      before { put "/flows/#{flow.id}/steps/#{step.id}/permissions" }
      it     { expect(response.status).to be_a_bad_request }
    end

    context 'with authentication' do
      context 'and user can\'t manage flows' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:manage), table_name: I18n.t(:flows)) }

        before { put "/flows/#{flow.id}/steps/#{step.id}/permissions", valid_params, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can manage flows' do
        context 'failure' do
          context 'when sent invalid permission_type' do
            before { put "/flows/#{flow.id}/steps/#{step.id}/permissions", valid_params.merge(permission_type: 'invalid'), auth(user) }

            it { expect(response.status).to be_a_bad_request }
            it { expect(response.body).to be_an_error(I18n.t(:permission_type_not_included)) }
          end
        end

        context 'successfully' do
          before { put "/flows/#{flow.id}/steps/#{step.id}/permissions", valid_params, auth(user) }

          it { expect(response.status).to be_a_success_request }
          it { expect(response.body).to be_a_success_message_with(I18n.t(:permissions_updated)) }
          it { expect(user.groups.first.reload.permission.send(valid_params[:permission_type])).to eql [step.id] }
        end
      end
    end
  end

  describe 'DELETE permissions' do
    let(:valid_params) { { group_ids: [user.groups.first.id], permission_type: 'can_view_step' } }
    let!(:flow)        { create(:flow) }
    let(:step)         { flow.steps.first }

    context 'no authentication' do
      before { delete "/flows/#{flow.id}/steps/#{step.id}/permissions" }
      it     { expect(response.status).to be_a_bad_request }
    end

    context 'with authentication' do
      context 'and user can\'t manage flows' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:manage), table_name: I18n.t(:flows)) }

        before { delete "/flows/#{flow.id}/steps/#{step.id}/permissions", valid_params, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can manage flows' do
        context 'failure' do
          context 'when sent invalid permission_type' do
            before { delete "/flows/#{flow.id}/steps/#{step.id}/permissions", valid_params.merge(permission_type: 'invalid'), auth(user) }

            it { expect(response.status).to be_a_bad_request }
            it { expect(response.body).to be_an_error(I18n.t(:permission_type_not_included)) }
          end
        end

        context 'successfully' do
          before { delete "/flows/#{flow.id}/steps/#{step.id}/permissions", valid_params, auth(user) }

          it { expect(response.status).to be_a_success_request }
          it { expect(response.body).to be_a_success_message_with(I18n.t(:permissions_updated)) }
          it { expect(user.groups.first.reload.permission.send(valid_params[:permission_type])).to eql([]) }
        end
      end
    end
  end
end
