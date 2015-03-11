require 'rails_helper'

describe Flow do
  describe 'validates' do
    context 'always' do
      it { should validate_presence_of(:title) }
      it { should validate_presence_of(:created_by) }
      it { should ensure_length_of(:title).is_at_most(100) }
      it { should ensure_length_of(:description).is_at_most(600) }
    end
  end
end
