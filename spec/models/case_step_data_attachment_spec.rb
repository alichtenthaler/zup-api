require 'app_helper'

describe CaseStepDataAttachment do
  describe 'associations' do
    it { should belong_to(:case_step_data_field) }
  end
end
