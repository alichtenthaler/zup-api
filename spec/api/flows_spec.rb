require 'spec_helper'

describe Flows::API, versioning: true do
  let(:user)       { create(:user) }
  let(:guest_user) { create(:guest_user) }

  describe 'on create' do
    let(:valid_params) { {title: 'title test', description: 'description test'} }

    context 'no authentication' do
      before { post '/flows', valid_params }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage flows' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:create), table_name: I18n.t(:flows)) }

        before { post '/flows', valid_params, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can manage flows' do
        context 'and failure' do
          context 'because validations fields' do
            before { post '/flows', {}, auth(user) }

            it { expect(response.status).to be_a_bad_request }
            it { expect(response.body).to be_an_error({'title' => [I18n.t('activerecord.errors.messages.blank')]}) }
          end
        end

        context 'successfully' do
          before { post '/flows', valid_params, auth(user) }

          it { expect(response.status).to be_a_requisition_created }
          it { expect(response.body).to be_a_success_message_with(I18n.t(:flow_created)) }
          it { expect(parsed_body['flow']).to be_an_entity_of(Flow.last, display_type: 'full') }
        end
      end
    end
  end

  describe 'on show' do
    let(:flow) { create(:flow, initial: true) }

    context 'no authentication' do
      before { get "/flows/#{flow.id}" }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage flows' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:view), table_name: I18n.t(:flows)) }

        before { get "/flows/#{flow.id}", {}, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can manage flows' do
        context 'and failure' do
          context 'because item not found' do
            before { get '/flows/123456789', {}, auth(user) }

            it { expect(response.status).to be_a_not_found }
            it { expect(response.body).to be_an_error('Couldn\'t find Flow with id=123456789') }
          end
        end

        context 'successfully' do
          context 'when sent display_type full' do
            before { get "/flows/#{flow.id}", {display_type: 'full'}, auth(user) }

            it { expect(response.status).to be_a_success_request }
            it { expect(parsed_body['flow']).to be_an_entity_of(flow, display_type: 'full') }
          end

          context 'when not sent display_type full' do
            before { get "/flows/#{flow.id}", {}, auth(user) }

            it { expect(response.status).to be_a_success_request }
            it { expect(parsed_body['flow']).to be_an_entity_of(flow) }
          end
        end
      end
    end
  end

  describe 'on delete' do
    let(:flow) { create(:flow, initial: true) }

    context 'no authentication' do
      before { delete "/flows/#{flow.id}" }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage flows' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:delete), table_name: I18n.t(:flows)) }

        before { delete "/flows/#{flow.id}", {}, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can manage flows' do
        context 'and failure' do
          context 'because item not found' do
            before { delete '/flows/123456789', {}, auth(user) }

            it { expect(response.status).to be_a_not_found }
            it { expect(response.body).to be_an_error('Couldn\'t find Flow with id=123456789') }
          end
        end

        context 'successfully' do
          before { delete "/flows/#{flow.id}", {}, auth(user) }

          it { expect(response.status).to be_a_success_request }
          it { expect(response.body).to be_a_success_message_with(I18n.t(:flow_deleted)) }
        end
      end
    end
  end

  describe 'on update' do
    let(:valid_params) { {title: 'new title test'} }
    let(:flow)         { create(:flow, initial: true, resolution_states: [create(:resolution_state, default: false)]) }

    context 'no authentication' do
      before { put "/flows/#{flow.id}", valid_params }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage flows' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:update), table_name: I18n.t(:flows)) }

        before { put "/flows/#{flow.id}", valid_params, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can manage flows' do
        context 'and failure' do
          context 'because validations fields' do
            before { put "/flows/#{flow.id}", {title: ''}, auth(user) }

            it { expect(response.status).to be_a_bad_request }
            it { expect(response.body).to be_an_error({'title' => [I18n.t('activerecord.errors.messages.blank')]}) }
          end
        end

        context 'successfully' do
          context 'with default resolution states' do
            before do
              flow.resolution_states.create(title: 'New Two Five Four', default: true)
              put "/flows/#{flow.id}", valid_params, auth(user)
            end

            it { expect(response.status).to be_a_success_request }
            it { expect(response.body).to be_a_success_message_with(I18n.t(:flow_updated)) }

            it 'should has new title \'new title test\'' do
              expect(flow.reload.title).to eql(valid_params[:title])
            end

            it 'should status be active' do
              expect(Flow.find(flow.id).status).to eql('active')
            end
          end

          context 'without default resolution states' do
            before { put "/flows/#{flow.id}", valid_params, auth(user) }

            it { expect(response.status).to be_a_success_request }
            it { expect(response.body).to be_a_success_message_with(I18n.t(:flow_updated)) }

            it 'should has new title \'new title test\'' do
              expect(flow.reload.title).to eql(valid_params[:title])
            end

            it 'should status be pending' do
              expect(Flow.find(flow.id).status).to eql('pending')
            end
          end
        end
      end
    end
  end

  describe 'on list' do
    context 'no authentication' do
      before { get '/flows' }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage flows' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:view), table_name: I18n.t(:flows)) }

        before { get '/flows', {}, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can manage flows' do
        let(:flow)       { create(:flow) }
        let(:other_flow) { create(:flow) }

        context 'with no items' do
          before { get '/flows', {}, auth(user) }

          it { expect(response.status).to be_a_success_request }
          it { expect(parsed_body['flows']).to be_empty }
        end

        context 'with one item' do
          before do
            flow
            get '/flows', {}, auth(user)
          end

          it { expect(response.status).to be_a_success_request }
          it { expect(parsed_body['flows']).to include_an_entity_of(flow) }
        end

        context 'with two items' do
          before do
            flow
            other_flow
            get '/flows', {}, auth(user)
          end

          it { expect(response.status).to be_a_success_request }
          it { expect(parsed_body['flows']).to include_an_entity_of(flow) }
          it { expect(parsed_body['flows']).to include_an_entity_of(other_flow) }
        end

        context 'with filter initial' do
          before do
            flow
            other_flow.update!(initial: true, updated_by: user)
            get '/flows', {initial: true}, auth(user)
          end

          it { expect(response.status).to be_a_success_request }
          it { expect(parsed_body['flows']).to_not include_an_entity_of(flow) }
          it { expect(parsed_body['flows']).to include_an_entity_of(other_flow) }
        end
      end
    end
  end

  describe 'on ancestors' do
    let!(:other_flow)  { create(:flow) }
    let!(:parent_flow) { create(:flow, initial: true) }
    let!(:flow)        { create(:flow) }
    let!(:step)        { create(:step, flow: parent_flow, child_flow: flow) }

    context 'no authentication' do
      before { get "/flows/#{flow.id}/ancestors" }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage flows' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:view), table_name: I18n.t(:flows)) }

        before { get "/flows/#{flow.id}/ancestors", {}, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can manage flows' do
        context 'successfully' do
          context 'when sent display_type full' do
            before { get "/flows/#{flow.id}/ancestors", {display_type: 'full'}, auth(user) }

            it { expect(response.status).to be_a_success_request }
            it { expect(parsed_body['flows']).to include_an_entity_of(flow) }
            it { expect(parsed_body['flows']).to include_an_entity_of(parent_flow.reload) }
            it { expect(parsed_body['flows']).to_not include_an_entity_of(other_flow) }
          end

          context 'when not sent display_type full' do
            before { get "/flows/#{flow.id}/ancestors", {}, auth(user) }

            it { expect(response.status).to be_a_success_request }
            it { expect(parsed_body['flows']).to include flow.id }
            it { expect(parsed_body['flows']).to include parent_flow.id }
            it { expect(parsed_body['flows']).to_not include other_flow.id }
          end
        end
      end
    end
  end

  describe 'PUT permissions' do
    let(:valid_params) { {group_ids: [user.groups.first.id], permission_type: 'flow_can_view_all_steps'} }
    let!(:flow)        { create(:flow) }

    context 'no authentication' do
      before { put "/flows/#{flow.id}/permissions" }
      it     { expect(response.status).to be_a_bad_request }
    end

    context 'with authentication' do
      context 'and user can\'t manage flows' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:manage), table_name: I18n.t(:flows)) }

        before { put "/flows/#{flow.id}/permissions", valid_params, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can manage flows' do
        context 'failure' do
          context 'when sent invalid permission_type' do
            before { put "/flows/#{flow.id}/permissions", valid_params.merge(permission_type: 'invalid'), auth(user) }

            it { expect(response.status).to be_a_bad_request }
            it { expect(response.body).to be_an_error(I18n.t(:permission_type_not_included)) }
          end
        end

        context 'successfully' do
          before { put "/flows/#{flow.id}/permissions", valid_params, auth(user) }

          it { expect(response.status).to be_a_success_request }
          it { expect(response.body).to be_a_success_message_with(I18n.t(:permissions_updated)) }
          it { expect(user.groups.first.reload.permission.send(valid_params[:permission_type])).to eql([flow.id]) }
        end
      end
    end
  end

  describe 'DELETE permissions' do
    let(:valid_params) { {group_ids: [user.groups.first.id], permission_type: 'flow_can_view_all_steps'} }
    let!(:flow)        { create(:flow) }

    context 'no authentication' do
      before { delete "/flows/#{flow.id}/permissions" }
      it     { expect(response.status).to be_a_bad_request }
    end

    context 'with authentication' do
      context 'and user can\'t manage flows' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:manage), table_name: I18n.t(:flows)) }

        before { delete "/flows/#{flow.id}/permissions", valid_params, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can manage flows' do
        context 'failure' do
          context 'when sent invalid permission_type' do
            before { delete "/flows/#{flow.id}/permissions", valid_params.merge(permission_type: 'invalid'), auth(user) }

            it { expect(response.status).to be_a_bad_request }
            it { expect(response.body).to be_an_error(I18n.t(:permission_type_not_included)) }
          end
        end

        context 'successfully' do
          before { delete "/flows/#{flow.id}/permissions", valid_params, auth(user) }

          it { expect(response.status).to be_a_success_request }
          it { expect(response.body).to be_a_success_message_with(I18n.t(:permissions_updated)) }
          it { expect(user.groups.first.reload.permission.send(valid_params[:permission_type])).to eql [] }
        end
      end
    end
  end
end
