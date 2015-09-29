require 'app_helper'

describe Step do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:flow) }
    it { should belong_to(:child_flow).class_name('Flow').with_foreign_key(:child_flow_id) }
    it { should have_many(:case_steps) }
    it { should have_many(:cases_log_entries) }
    it { should have_many(:triggers).dependent(:destroy) }
    it { should have_many(:fields).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(100) }
    it { should validate_presence_of(:step_type) }
    it { should validate_inclusion_of(:step_type).in_array(%w(form flow)) }
  end

  describe 'callbacks' do
    describe 'before_update :set_draft' do
      context 'draft changed to true' do
        let!(:step) { create(:step, draft: false) }

        it 'doesnt call #set_draft' do
          expect(step).to_not receive(:set_draft)
          step.draft = true
          step.save
        end
      end

      context 'draft changed to false' do
        let!(:step) { create(:step, draft: true) }

        it 'doesnt call #set_draft' do
          expect(step).to_not receive(:set_draft)
          step.draft = false
          step.save
        end
      end

      context 'draft didint change' do
        let!(:step) { create(:step, title: 'Titulo 1') }

        subject(:update_step) do
          step.title = 'Titulo 2'
          step.save
        end

        it 'calls #set_draft' do
          expect(step).to receive(:set_draft).and_call_original
          update_step
        end

        it "updates step's flow 'updated_by' field to step's user" do
          step.flow.update_column(:updated_by_id, 0)

          expect do
            update_step
          end.to change(step.flow, :updated_by).to(step.user)
        end

        it "updates step's flow 'draft' field to true" do
          step.flow.update_column(:draft, false)

          expect do
            update_step
          end.to change(step.flow, :draft).to(true)
        end

        it "updates step's 'draft' field to true" do
          step.update_column(:draft, false)

          expect do
            update_step
          end.to change(step, :draft).to(true)
        end
      end

      context 'regression test' do
        let!(:user) { create(:user) }
        let!(:flow) { create(:flow_without_steps) }
        let!(:step) { create(:step, step_type: 'flow', flow: flow, user: user) }
        let!(:field) { create(:field, step: step) }

        it 'doesnt raise a validation error on Flow' do
          expect(field.save).to be_truthy
          expect(field.step.flow.errors.present?).to be_falsy
        end
      end
    end
  end
end
