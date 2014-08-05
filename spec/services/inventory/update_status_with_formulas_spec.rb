require "spec_helper"

describe Inventory::UpdateStatusWithFormulas do
  let!(:item) { create(:inventory_item) }
  let!(:formula) do
    create(:inventory_formula, category: item.category)
  end

  subject { described_class.new(item) }

  it "updates the item with formulas" do
    expect(item.status).to_not eq(formula.status)
    subject.check_and_update!
    expect(item.reload.status).to eq(formula.status)
  end

  it "creates a new history for formula" do
    expect(formula.histories).to be_empty
    subject.check_and_update!
    expect(formula.histories).to_not be_empty
    history = formula.histories.last

    expect(history.item).to eq(item)
  end

  it "creates a new correct alert for formula" do
    subject.check_and_update!
    expect(formula.alerts).to_not be_empty

    created_alert = formula.alerts.last
    expect(created_alert.affected_items).to include(item)
    expect(created_alert.sent?).to be_falsy
  end
end
