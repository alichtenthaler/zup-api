require 'rails_helper'

describe TriggerCondition do
  describe 'validations' do
    it { should validate_presence_of(:condition_type) }
    it { should validate_presence_of(:values) }
    it { should ensure_inclusion_of(:condition_type).in_array(%w{== != > < inc}) }
  end
end
