require "spec_helper"

describe Inventory::UpdateItemFromCategory do
  let!(:item) { create(:inventory_item) }
  let(:item_data) { item.data.where(field: { kind: 'text' }).first }
  let!(:item_params) do
    {
      'data' => {
        item_data.field.id => 'updated content'
      }
    }
  end

  context "updating an existant item" do
    it "updates the item" do
      described_class.new(item, item_params['data']).update!
      expect(item_data.reload.content).to eq('updated content')
    end
  end
end
