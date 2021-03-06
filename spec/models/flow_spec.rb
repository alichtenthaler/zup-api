require 'app_helper'

describe Flow do
  describe 'associations' do
    it { should belong_to(:created_by).class_name('User').with_foreign_key(:created_by_id) }
    it { should belong_to(:updated_by).class_name('User').with_foreign_key(:updated_by_id) }
    it { should have_many(:cases).class_name('Case').with_foreign_key(:initial_flow_id) }
    it { should have_many(:parent_steps).class_name('Step').with_foreign_key(:child_flow_id) }
    it { should have_many(:steps).dependent(:destroy) }
    it { should have_many(:resolution_states).dependent(:destroy) }
    it { should have_many(:cases_log_entries) }
    it { should have_many(:cases_log_entries_as_new_flow).class_name('CasesLogEntry').with_foreign_key(:new_flow_id) }
  end

  describe 'search' do
    context 'by status' do
      let!(:pending_flow) { create(:flow) }
      let!(:inactive_flow) { create(:flow).inactive! }

      it { expect(Flow.search('pending')).to include(pending_flow) }
      it { expect(Flow.search('pending')).not_to include(inactive_flow) }
      it { expect(Flow.search('inactive')).not_to include(pending_flow) }
    end

    context 'by title' do
      let!(:flow) { create(:flow) }

      it { expect(Flow.search(flow.title)).to include(flow) }
      it { expect(Flow.search(flow.title.split('').shuffle.join)).to_not include(flow) }
    end

    context 'by resolution states' do
      let!(:flow) { create(:flow) }
      let!(:resolution_state) { create(:resolution_state, flow: flow) }

      it { expect(Flow.search(resolution_state.title)).to include(flow) }
      it { expect(Flow.search(resolution_state.title.split('').shuffle.join)).to_not include(flow) }
    end

    context 'by steps' do
      let!(:flow) { create(:flow) }
      let!(:step) { create(:step, flow: flow) }

      it { expect(Flow.search(step.title)).to include(flow) }
      it { expect(Flow.search(step.title.split('').shuffle.join)).to_not include(flow) }
    end
  end

  describe 'scopes' do
    describe 'active' do
      let!(:active_flow) { create(:flow, status: 'active') }
      let!(:inactive_flow) { create(:flow, status: 'inactive') }
      let!(:pending_flow) { create(:flow, status: 'pending') }

      it 'returns flows with any status but inactive' do
        expect(Flow.active).to include(active_flow)
        expect(Flow.active).to include(pending_flow)
        expect(Flow.active).to_not include(inactive_flow)
      end
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:created_by) }
    it { should validate_presence_of(:updated_by).on(:update) }
    it { should validate_length_of(:title).is_at_most(100) }
    it { should validate_length_of(:description).is_at_most(600) }
    it { should validate_inclusion_of(:status).in_array(%w(active pending inactive)) }
  end

  describe '#the_version' do
    context 'when the flow is initial version' do
      let(:flow) { create(:flow, initial: true) }

      it { expect(flow.the_version).to be_equal(flow) }
      it { expect(flow.the_version(true)).to be_equal(flow) }
    end
  end
end
