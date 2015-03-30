require 'spec_helper'

describe ExecuteFormulaForItems do
  let(:user) { create(:user) }
  let(:formula) { create(:inventory_formula, :with_conditions) }

  subject { described_class.new }

  describe '#perform' do
    let(:status) { create(:inventory_status) }
    let!(:item) { create(:inventory_item, category: formula.category, status: status) }

    it 'calls `check_and_update!` for the item' do
      expect_any_instance_of(Inventory::UpdateStatusWithFormulas).to \
        receive(:check_and_update!)
      subject.perform(user.id, formula.id, [item.id])
    end
  end
end
