require 'app_helper'

describe CasesLogEntry do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:flow) }
    it { should belong_to(:step) }
    it { should belong_to(:case) }
    it { should belong_to(:new_flow).class_name('Flow').with_foreign_key(:new_flow_id) }
    it { should belong_to(:before_user).class_name('User').with_foreign_key(:before_user_id) }
    it { should belong_to(:after_user).class_name('User').with_foreign_key(:after_user_id) }
    it { should belong_to(:before_group).class_name('Group').with_foreign_key(:before_group_id) }
    it { should belong_to(:after_group).class_name('Group').with_foreign_key(:after_group_id) }
    it { should belong_to(:child_case).class_name('Case').with_foreign_key(:child_case_id) }
  end

  describe 'validations' do
    it { should validate_presence_of(:action) }
    it { should validate_inclusion_of(:action).in_array(CasesLogEntry::ACTION_TYPES) }
  end
end
