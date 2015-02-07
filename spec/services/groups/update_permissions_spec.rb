require "spec_helper"

describe Groups::UpdatePermissions do
  let(:group) { create(:group) }

  describe ".update" do
    let(:object) do
      double(Inventory::Item, id: 1)
    end
    let(:permission_name) { :inventory_categories_can_view }

    context "appending id to array" do
      it "appends the object to array of permission" do
        expect(group.permission.inventory_categories_can_view).to be_empty
        described_class.update([group.id], object, permission_name)
        expect(group.permission.reload.inventory_categories_can_view).to eq([object.id])
      end
    end

    context "other groups with that id" do
      let!(:other_group) { create(:group) }

      before do
        other_group.permission.update(inventory_categories_can_view: [object.id])
      end

      it "removes the object it from the array of permission" do
        described_class.update([group.id], object, permission_name)
        expect(other_group.permission.reload.inventory_categories_can_view).to be_empty
      end
    end
  end
end
