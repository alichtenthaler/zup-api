require 'app_helper'

describe Field do
  describe 'validates' do
    let(:valid_types) do
      %w{integer decimal meter centimeter kilometer year month day hour second
        angle date time date_time cpf cnpj url email image attachment previous_field}
    end

    it { should validate_presence_of(:title) }
    it { should ensure_inclusion_of(:field_type).in_array(valid_types) }
    it { should_not validate_presence_of(:filter) }
    it { should_not validate_presence_of(:origin_field_id) }

    context 'when field_type is previous_field' do
      subject { build(:field, field_type: 'previous_field') }
      it      { should validate_presence_of(:origin_field_id) }
    end
  end
end
