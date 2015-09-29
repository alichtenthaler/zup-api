require 'app_helper'

describe CaseStepDataImage do
  describe 'associations' do
    it { should belong_to(:case_step_data_field) }
  end
end
