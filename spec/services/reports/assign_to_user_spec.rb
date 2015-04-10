require 'rails_helper'

describe Reports::AssignToUser do
  let(:category) { create(:reports_category_with_statuses) }
  let(:report) { create(:reports_item, category: category) }
  let(:user) { create(:user) }
  let(:user_to_assign) { create(:user) }

  subject { described_class.new(report, user) }

  describe '#assign!' do
    let(:group) { create(:group) }

    before do
      category.solver_groups = [group]
      category.save!

      report.update(assigned_group: group)
    end

    context 'user belongs to assigned_group' do
      before do
        user_to_assign.groups << group
        user_to_assign.save!
      end

      it 'assigns report to user' do
        subject.assign!(user_to_assign)
        expect(report.reload.assigned_user).to eq(user_to_assign)
      end
    end

    context 'user doesn\'t belongs to group' do
      it 'doesn\'t assign user and raise error' do
        expect { subject.assign!(user_to_assign) }.to raise_error
      end
    end
  end
end
