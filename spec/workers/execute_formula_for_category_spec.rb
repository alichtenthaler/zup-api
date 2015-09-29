require 'spec_helper'

describe ExecuteFormulaForCategory do
  let!(:user) { create(:user) }
  let!(:formula) { create(:inventory_formula, :with_conditions) }

  subject { ExecuteFormulaForCategory.new.perform(user.id, formula.id) }

  describe '#perform' do
    let!(:status) { create(:inventory_status) }
    let!(:item1) { create(:inventory_item, category: formula.category, status: status) }
    let!(:item2) { create(:inventory_item, category: formula.category, status: status) }

    it 'creates a job' do
      expect do
        subject
      end.to change(ExecuteFormulaForItems.jobs, :size).by(1)
    end

    it 'calls ExecuteFormulaForItems with the correct params' do
      expect(ExecuteFormulaForItems).to receive(:perform_async).with(user.id, formula.id, [item1.id, item2.id])
      subject
    end
  end
end
