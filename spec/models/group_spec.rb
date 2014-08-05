require 'spec_helper'

describe Group do
  it "validates name" do
    group = Group.new
    expect(group).to_not be_valid
    group.errors.should include(:name)
  end

  it "has relation with users" do
    group = create(:group)
    user = create(:user)

    group.users << user
    group.save

    group = Group.find(group.id)
    expect(group.users).to include(user)
  end

  it "isn't a guest if nothing is specified" do
    group = create(:group, guest: nil)
    expect(group.guest).to eq(false)
  end

  describe ".with_permission" do
    let(:group) { create(:group) }
    let(:groups) { create_list(:group, 10) }

    before :each do
      group.manage_users = true
      group.save!
    end

    it "returns groups where the given permission is true" do
      expect(Group.with_permission(:manage_users)).to eq(group)
    end
  end

  describe "permissions" do
    let(:group) { create(:group) }

    it "key with array content are saved correctly" do
      ids = [1, 2, 4, 5]
      group.permissions = {
        groups_can_view: ids
      }
      group.save!

      expect(Group.last.groups_can_view.map(&:to_i)).to eq(ids)
    end

    it "key with array content are saved correctly with explicit setter" do
      ids = [1, 2, 4, 5]
      group.groups_can_view = ids
      group.save!

      expect(Group.last.groups_can_view.map(&:to_i)).to eq(ids)
    end

    it "key with boolean content are saved correctly" do
      group.permissions = {
        view_categories: true
      }

      group.save!

      expect(Group.last.view_categories).to eq(true)
      expect(Group.last.view_categories.class).to eq(TrueClass)
    end

    it "key with boolean content are saved correctly with explicit setter" do
      group.view_categories = true
      group.save!

      expect(Group.last.view_categories).to eq(true)
      expect(Group.last.view_categories.class).to eq(TrueClass)
    end
  end
end
