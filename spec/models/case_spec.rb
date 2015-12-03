require 'app_helper'

describe Case do
  describe 'associations' do
    it { should have_many(:cases_log_entries) }
    it { should have_many(:case_steps) }
    it { should have_many(:children_cases).class_name('Case').with_foreign_key(:original_case_id) }
    it { should have_many(:cases_log_entries_as_child_case).class_name('CasesLogEntry').with_foreign_key(:child_case_id) }
    it { should belong_to(:initial_flow).class_name('Flow').with_foreign_key(:initial_flow_id) }
    it { should belong_to(:created_by).class_name('User').with_foreign_key(:created_by_id) }
    it { should belong_to(:updated_by).class_name('User').with_foreign_key(:updated_by_id) }
    it { should belong_to(:resolution_state).class_name('ResolutionState').with_foreign_key(:resolution_state_id) }
    it { should belong_to(:original_case).class_name('Case').with_foreign_key(:original_case_id) }
  end

  describe 'nested attributes' do
    it { should accept_nested_attributes_for(:case_steps) }
  end

  describe 'search' do
    context 'by status' do
      let!(:active_case) { create(:case, status: 'active') }
      let!(:inactive_case) { create(:case, status: 'inactive') }

      it { expect(Case.search('active')).to include(active_case) }
      it { expect(Case.search('active')).not_to include(inactive_case) }
      it { expect(Case.search('inactive')).not_to include(active_case) }
    end

    context 'by resolution states' do
      let!(:flow) { create(:flow) }
      let!(:resolution_state) { create(:resolution_state, flow: flow) }
      let!(:kase) { create(:case, resolution_state: resolution_state) }

      it { expect(Case.search(resolution_state.title)).to include(kase) }
      it { expect(Case.search(resolution_state.title.split('').shuffle.join)).to_not include(kase) }
    end

    context 'by completed steps' do
      let!(:step) { create(:step) }
      let!(:kase) { create(:case) }
      let!(:case_step) { create(:case_step, step: step, case: kase) }

      it { expect(Case.search(step.title)).to include(kase) }
      it { expect(Case.search(step.title.split('').shuffle.join)).to_not include(kase) }
    end

    context 'by flow' do
      let!(:flow) { create(:flow, initial: true) }
      let!(:kase) { create(:case, initial_flow: flow) }

      it { expect(Case.search(flow.title)).to include(kase) }
      it { expect(Case.search(flow.title.split('').shuffle.join)).to_not include(kase) }
    end
  end

  describe 'scopes' do
    let!(:active_case) { create(:case, status: 'active') }
    let!(:pending_case) { create(:case, status: 'pending') }
    let!(:transfer_case) { create(:case, status: 'transfer') }
    let!(:not_satisfied_case) { create(:case, status: 'not_satisfied') }
    let!(:finished_case) { create(:case, status: 'finished') }
    let!(:inactive_case) { create(:case, status: 'inactive') }

    describe 'active' do
      subject(:query) { Case.active }

      it 'returns active cases' do
        expect(query).to include(active_case)
      end

      it 'returns pending cases' do
        expect(query).to include(pending_case)
      end

      it 'returns transfer cases' do
        expect(query).to include(transfer_case)
      end

      it 'returns not_satisfied cases' do
        expect(query).to include(not_satisfied_case)
      end

      it 'doesnt return finished cases' do
        expect(query).to_not include(finished_case)
      end

      it 'doesnt return inactive cases' do
        expect(query).to_not include(inactive_case)
      end
    end

    describe 'not_inactive' do
      subject(:query) { Case.not_inactive }

      it 'returns active cases' do
        expect(query).to include(active_case)
      end

      it 'returns pending cases' do
        expect(query).to include(pending_case)
      end

      it 'returns transfer cases' do
        expect(query).to include(transfer_case)
      end

      it 'returns not_satisfied cases' do
        expect(query).to include(not_satisfied_case)
      end

      it 'returns finished cases' do
        expect(query).to include(finished_case)
      end

      it 'doesnt return inactive cases' do
        expect(query).to_not include(inactive_case)
      end
    end

    describe 'inactive' do
      subject(:query) { Case.inactive }

      it 'doesnt return active cases' do
        expect(query).to_not include(active_case)
      end

      it 'doesnt return pending cases' do
        expect(query).to_not include(pending_case)
      end

      it 'doesnt return transfer cases' do
        expect(query).to_not include(transfer_case)
      end

      it 'doesnt return not_satisfied cases' do
        expect(query).to_not include(not_satisfied_case)
      end

      it 'doesnt return finished cases' do
        expect(query).to_not include(finished_case)
      end

      it 'returns inactive cases' do
        expect(query).to include(inactive_case)
      end
    end
  end

  describe 'validations' do
    describe 'presence' do
      [:created_by_id, :initial_flow_id].each do |attr|
        it { should validate_presence_of(attr) }
      end
    end

    describe 'inclusion in status field' do
      it { should validate_inclusion_of(:status).in_array(%w(active pending finished inactive transfer not_satisfied)) }
    end

    describe '#not_change_initial_flow' do
      let!(:another_flow) { create(:flow) }
      let!(:case_instance) { create(:case) }

      it 'raises an error if changes the initial_flow_id field' do
        case_instance.initial_flow = another_flow
        expect(case_instance.save).to be_falsy
      end
    end
  end

  describe 'log!' do
    let!(:flow) { create(:flow) }
    let!(:case_instance) { create(:case, initial_flow: flow) }

    context 'with options' do
      let(:user) { create(:user) }

      subject(:call_log) { case_instance.log!('create_case', user: user, flow_version: 98) }

      it 'creates a CasesLogEntry' do
        expect do
          call_log
        end.to change { CasesLogEntry.count }.by(1)
      end

      it 'creates the CasesLogEntry overwriting its default values' do
        call_log
        cases_log_entry = CasesLogEntry.last

        expect(cases_log_entry.action).to eq('create_case')
        expect(cases_log_entry.user_id).to eq(user.id)
        expect(cases_log_entry.flow_id).to eq(flow.id)
        expect(cases_log_entry.flow_version).to eq(98)
        expect(cases_log_entry.case_id).to eq(case_instance.id)
        expect(cases_log_entry.step_id).to be_nil
      end
    end

    context 'without options' do
      let(:user) { create(:user) }

      subject(:call_log) { case_instance.log!('create_case') }

      it 'creates a CasesLogEntry' do
        expect do
          call_log
        end.to change { CasesLogEntry.count }.by(1)
      end

      it 'creates the CasesLogEntry with the default values' do
        call_log
        cases_log_entry = CasesLogEntry.last

        expect(cases_log_entry.action).to eq('create_case')
        expect(cases_log_entry.user_id).to eq(case_instance.created_by.id)
        expect(cases_log_entry.flow_id).to eq(flow.id)
        expect(cases_log_entry.flow_version).to eq(1)
        expect(cases_log_entry.case_id).to eq(case_instance.id)
        expect(cases_log_entry.step_id).to be_nil
      end
    end

    context 'with an action that doesnt exist' do
      subject(:call_log) { case_instance.log!('bla') }

      it 'raises an error' do
        expect do
          call_log
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
