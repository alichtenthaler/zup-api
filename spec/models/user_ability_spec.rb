require "spec_helper"

describe UserAbility do
  let(:user) { create(:user, groups: []) }

  subject { described_class.new(user) }

  context "manage permissions" do

    context "managing users" do
      let(:other_user) { create(:user) }
      let(:group) do
        create(:group, manage_users: true)
      end

      it "can manage the given entity" do
        user.groups << group
        expect(subject.can?(:manage, User)).to be_truthy
        expect(subject.can?(:manage, user)).to be_truthy
        expect(subject.can?(:manage, other_user)).to be_truthy
      end

      it "can't manage the given entity" do
        expect(subject.can?(:manage, other_user)).to be_falsy
        expect(subject.can?(:manage, user)).to be_truthy
      end
    end

    context "managing groups" do
      let(:other_group) { create(:group) }
      let(:group) { create(:group) }

      before { user.groups << group }

      it "can manage the given group" do
        group.groups_can_edit = [other_group.id]
        group.permissions_will_change!
        group.save!
        expect(subject.can?(:edit, other_group)).to be_truthy
      end

      it "can't manage the group" do
        expect(subject.can?(:edit, other_group)).to be_falsy
      end
    end

  end
end
