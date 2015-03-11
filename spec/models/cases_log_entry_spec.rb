require 'rails_helper'

describe CasesLogEntry do
  describe 'validations' do
    it { should validate_presence_of(:action) }
    it { should ensure_inclusion_of(:action).in_array(%w{create_case next_step transfer_case transfer_flow delete_case}) }
  end
end
