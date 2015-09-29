require 'app_helper'

describe CaseStepDataField do
  describe 'associations' do
    it { should belong_to(:field) }
    it { should belong_to(:case_step) }
    it { should have_many(:case_step_data_images) }
    it { should have_many(:case_step_data_attachments) }
  end

  describe 'validations' do
    it { should validate_presence_of(:field_id) }
  end
end
