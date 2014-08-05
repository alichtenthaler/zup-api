require 'spec_helper'

describe Step do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should ensure_length_of(:title).is_at_most(100) }
    it { should validate_presence_of(:step_type) }
    it { should ensure_inclusion_of(:step_type).in_array(%w(form flow)) }
  end
end
