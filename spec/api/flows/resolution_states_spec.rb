require 'app_helper'

describe Flows::API do
  let(:user) { create(:user) }
  let(:guest_user) { create(:guest_user) }
  let(:valid_params) do
    { title: 'title test', description: 'description test',
      resolution_states: [{ title: 'Done', default: false }, { title: 'Open', default: true }] }
  end

  describe 'when creating a flow with resolution states' do
    describe 'and the user does not have permission' do
      before { post '/flows', valid_params, auth(guest_user) }

      let(:error) { I18n.t(:permission_denied, action: I18n.t(:create), table_name: I18n.t(:flows)) }
      it { expect(response.status).to be_a_forbidden }
      it { expect(parsed_body).to be_an_error(error) }
    end

    describe 'and the user has permission' do
      before { post '/flows', valid_params, auth(user) }
      it { expect(response.status).to be_a_requisition_created }
      it { expect(response.body).to be_a_success_message_with(I18n.t(:flow_created)) }
      it { expect(parsed_body['flow']['resolution_states'].count).to eq(2) }

      let(:done_state) { parsed_body['flow']['resolution_states'].select { |rs| rs['title'] == 'Done' }.first }
      it { expect(done_state['default']).to be_falsey }

      let(:open_state) { parsed_body['flow']['resolution_states'].select { |rs| rs['title'] == 'Open' }.first }
      it { expect(open_state['default']).to be_truthy }
    end
  end

  describe 'when updating a flow with resolution states' do
    let(:new_state) { { title: 'New state', default: false } }
    let(:new_default_state) { { title: 'New state', default: true } }

    describe 'and the user adds a new resolution state' do
      context 'that is not set as default' do
        let(:flow) { create(:flow, initial: true, resolution_states: [build(:resolution_state, default: true)]) }
        before do
          put "/flows/#{flow.id}", { resolution_states: flow.resolution_states.map { |rs| rs.as_json } << new_state }, auth(user)
          flow.reload
        end

        let(:resolution_states) { flow.resolution_states }
        it { expect(resolution_states.count).to eq(2) }
        it { expect(resolution_states.last.title).to eq(new_state[:title]) }
        it { expect(resolution_states.last.default).to be_falsey }
      end

      context 'using a new default state' do
        let(:flow) { create(:flow, initial: true, resolution_states: [build(:resolution_state, default: true)]) }
        before do
          current_rs = flow.resolution_states.each { |rs| rs.default = false }.map { |rs| rs.as_json }
          put "/flows/#{flow.id}", { resolution_states: current_rs << new_default_state }, auth(user)
          flow.reload
        end

        let(:resolution_states) { flow.resolution_states }
        it { expect(resolution_states.count).to eq(2) }
        it { expect(resolution_states.last.title).to eq(new_default_state[:title]) }
        it { expect(resolution_states.first.default).to be_falsey }
        it { expect(resolution_states.last.default).to be_truthy }
      end
    end

    describe 'and the user modifies an existing resolution state' do
      let(:flow) { create(:flow, initial: true, resolution_states: [build(:resolution_state, default: true)]) }
      let(:state_id) { flow.resolution_states.first.id }

      before do
        current_rs = flow.resolution_states.each { |rs| rs.default = false }.map { |rs| rs.as_json }
        current_rs[0]['title'] = 'Modified title'
        current_rs[0]['active'] = false
        put "/flows/#{flow.id}", { resolution_states: current_rs }, auth(user)
        flow.reload
      end

      it { expect(flow.resolution_states.first.id).to eq(state_id) }
      it { expect(flow.resolution_states.first.title).to eq('Modified title') }
      it { expect(flow.resolution_states.first.active).to be_falsey }
    end
  end
end
