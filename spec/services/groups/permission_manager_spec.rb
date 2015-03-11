require "rails_helper"

describe Groups::PermissionManager do
  let!(:group) { create(:group) }

  subject { described_class.new(group) }

  describe "#add_with_objects" do
    let(:permission_name) { :inventory_categories_can_view }
    let(:object) { create(:inventory_category) }

    it "adds the id of the object to the permissions" do
      subject.add_with_objects(permission_name, [object.id])
      expect(group.permission.reload.inventory_categories_can_view).to include(object.id)
    end
  end

  describe "#remove_with_objects" do
    let(:permission_name) { :inventory_categories_can_view }
    let(:object) { create(:inventory_category) }

    before do
      group.permission.update(permission_name => [object.id])
    end

    it "removes the id of the object from the permission" do
      subject.remove_with_objects(permission_name, [object.id])
      expect(group.permission.reload.inventory_categories_can_view).to_not include(object.id)
    end
  end

  describe "#add" do
    let(:permission_name) { :manage_users }

    before do
      group.permission.update(permission_name => false)
    end

    it "sets the permission as true" do
      subject.add(permission_name)
      expect(group.permission.reload.send(permission_name)).to be_truthy
    end
  end

  describe "#remove" do
    let(:permission_name) { :manage_users }

    before do
      group.permission.update(permission_name => true)
    end

    it "sets the permission as true" do
      subject.remove(permission_name)
      expect(group.permission.reload.send(permission_name)).to be_falsy
    end
  end

  describe "#fetch" do
    let(:inventory_category) { create(:inventory_category) }
    before do
      group.permission.update(
        inventory_categories_can_edit: [inventory_category.id],
        inventory_categories_can_view: [inventory_category.id],
        manage_reports: true
      )
    end

    it "returns rows of data" do
      data = subject.fetch

      expect(data).to match_array([
        {
          permission_type: :inventory,
          object: an_instance_of(Inventory::Category::Entity),
          permission_names: ["inventory_categories_can_edit", "inventory_categories_can_view"]
        },
        {
          permission_type: :report,
          permission_names: "manage_reports"
        }
      ])
    end
  end

end
