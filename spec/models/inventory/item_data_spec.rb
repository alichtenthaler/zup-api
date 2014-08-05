require 'spec_helper'

describe Inventory::ItemData do
  context "with field type of checkbox" do
    let(:valid_content) { ["Test1", "Test2"] }

    it "accepts array as content" do
      field = create(:inventory_field, kind: "checkbox")
      item_data = create(:inventory_item_data, field: field, content: valid_content)
      expect(Inventory::ItemData.find(item_data.id).content).to eq(valid_content)
    end
  end
end
