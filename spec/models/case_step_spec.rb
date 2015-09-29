require 'app_helper'

describe CaseStep do
  describe 'associations' do
    it { should belong_to(:case) }
    it { should belong_to(:step) }
    xit { should belong_to(:trigger) }
    it { should have_many(:case_step_data_fields) }
    it { should belong_to(:created_by).class_name('User').with_foreign_key(:created_by_id) }
    it { should belong_to(:updated_by).class_name('User').with_foreign_key(:updated_by_id) }
    it { should belong_to(:responsible_user).class_name('User').with_foreign_key(:responsible_user_id) }
    it { should belong_to(:responsible_group).class_name('Group').with_foreign_key(:responsible_group_id) }
  end

  describe 'nested attributes' do
    it { should accept_nested_attributes_for(:case_step_data_fields) }
  end

  describe 'validations' do
    it { should validate_uniqueness_of(:step_id).scoped_to(:case_id) }
  end
end
