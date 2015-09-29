require 'spec_helper'

describe ExecuteFormulaForCategory do
  let(:user) { create(:user) }
  let(:formula) { create(:inventory_formula, :with_conditions) }

  subject { described_class.new }

  describe '#perform' do
    let(:status) { create(:inventory_status) }
    let!(:item) { create(:inventory_item, category: formula.category, status: status) }

    it 'calls `check_and_update!` for the item' do
      expect do
        subject.perform(user.id, formula.id)
      end.to change(ExecuteFormulaForItems.jobs, :size).by(1)
    end
  end
end
