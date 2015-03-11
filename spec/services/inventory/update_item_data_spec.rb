require "spec_helper"

describe Inventory::UpdateItemData do
  let!(:item) { create(:inventory_item) }
  let(:item_data) { item.data.where(field: { kind: 'text' }).first }
  let(:user) { create(:user) }
  let!(:item_params) do
    {
      'data' => {
        item_data.field.id => 'updated content'
      }
    }
  end

  context "updating an existant item" do
    it "updates the item" do
      described_class.new(item, item_params['data'], user).update!
      expect(item_data.reload.content).to eq('updated content')
    end

    it "creates a history entry" do
      described_class.new(item, item_params['data'], user).update!

      entry = item.histories.last
      expect(entry).to_not be_blank
      expect(entry.objects).to match_array([item_data.field])
    end
  end
end
