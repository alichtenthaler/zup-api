require 'rails_helper'

describe Flows::ResolutionStates::API do
  let(:user)       { create(:user) }
  let(:guest_user) { create(:guest_user) }

  describe 'on create' do
    let!(:flow)        { create(:flow_without_relation) }
    let(:valid_params) { {title: 'Success', default: true} }

    context 'no authentication' do
      before { post "/flows/#{flow.id}/resolution_states", valid_params }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage resolution state' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:create), table_name: I18n.t(:resolution_states)) }

        before { post "/flows/#{flow.id}/resolution_states", valid_params, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can manage resolution state' do
        context 'and failure' do
          context 'because validations fields' do
            before { post "/flows/#{flow.id}/resolution_states", {}, auth(user) }

            it { expect(response.status).to be_a_bad_request }
            it { expect(response.body).to be_an_error({'title' => [I18n.t('activerecord.errors.messages.blank')]}) }
          end
        end

        context 'successfully' do
          context 'one with default' do
            let(:title) { valid_params.delete(:title) }
            before { post "/flows/#{flow.id}/resolution_states", valid_params, auth(user) }

            it { expect(response.status).to be_a_requisition_created }
            it { expect(response.body).to be_a_success_message_with(I18n.t(:resolution_state_created)) }
            it { expect(parsed_body['resolution_state']).to be_an_entity_of(flow.resolution_states.find_by(title: title)) }
          end

          context 'exists one with default and create another without default' do
            let!(:first_resolution) { flow.resolution_states.create(title:'test with default', default: true) }
            before { post "/flows/#{flow.id}/resolution_states", valid_params.except(:default), auth(user) }

            it { expect(response.status).to be_a_requisition_created }
            it { expect(response.body).to be_a_success_message_with(I18n.t(:resolution_state_created)) }
            it { expect(parsed_body['resolution_state']).to be_an_entity_of(flow.resolution_states.find_by(valid_params.slice(:title))) }

            it 'should total resolution states for this Flow be 2' do
              expect(flow.resolution_states.count).to eql(2)
            end
          end
        end
      end
    end
  end

  describe 'on update' do
    let(:flow)         { create(:flow) }
    let!(:resolution)  { flow.resolution_states.first }
    let(:valid_params) { {title: 'Success', default: true} }

    context 'no authentication' do
      before { put "/flows/#{flow.id}/resolution_states/#{resolution.id}", valid_params }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage resolution state' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:update), table_name: I18n.t(:resolution_states)) }

        before { put "/flows/#{flow.id}/resolution_states/#{resolution.id}", valid_params, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can manage resolution state' do
        context 'and failure' do
          context 'because validations fields' do
            before { put "/flows/#{flow.id}/resolution_states/#{resolution.id}", {}, auth(user) }

            it { expect(response.status).to be_a_bad_request }
            it { expect(response.body).to be_an_error({'title' => [I18n.t('activerecord.errors.messages.blank')]}) }
          end

          context 'because not found' do
            before { put "/flows/#{flow.id}/resolution_states/12345678", valid_params, auth(user) }

            it { expect(response.status).to be_a_not_found }
            it { expect(response.body).to be_an_error('Couldn\'t find ResolutionState with id=12345678 [WHERE "resolution_states"."flow_id" = $1]') }
          end
        end

        context 'successfully' do
          context 'one with default' do
            before { put "/flows/#{flow.id}/resolution_states/#{resolution.id}", valid_params, auth(user) }

            it { expect(response.status).to be_a_success_request }
            it { expect(response.body).to be_a_success_message_with(I18n.t(:resolution_state_updated)) }
          end
        end
      end
    end
  end

  describe 'on delete' do
    let(:flow)         { create(:flow) }
    let!(:resolution)  { flow.resolution_states.first }

    context 'no authentication' do
      before { delete "/flows/#{flow.id}/resolution_states/#{resolution.id}" }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage resolution state' do
        let(:error) { I18n.t(:permission_denied, action: I18n.t(:delete), table_name: I18n.t(:resolution_states)) }

        before { delete "/flows/#{flow.id}/resolution_states/#{resolution.id}", {}, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
        it     { expect(parsed_body).to be_an_error(error) }
      end

      context 'and user can manage resolution state' do
        context 'and failure' do
          context 'because not found' do
            before { delete "/flows/#{flow.id}/resolution_states/12345678", {}, auth(user) }

            it { expect(response.status).to be_a_not_found }
            it { expect(response.body).to be_an_error('Couldn\'t find ResolutionState with id=12345678 [WHERE "resolution_states"."flow_id" = $1]') }
          end
        end

        context 'successfully' do
          before { delete "/flows/#{flow.id}/resolution_states/#{resolution.id}", {}, auth(user) }

          it { expect(response.status).to be_a_success_request }
          it { expect(response.body).to be_a_success_message_with(I18n.t(:resolution_state_deleted)) }
        end
      end
    end
  end
end
