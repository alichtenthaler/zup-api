require 'app_helper'

describe Field do
  describe 'validates' do
    describe 'presence' do
      [:title, :step, :user].each do |attr|
        it { should validate_presence_of(attr) }
      end

      it { should_not validate_presence_of(:filter) }
      it { should_not validate_presence_of(:origin_field_id) }
    end

    describe 'inclusion of field_type' do
      let(:valid_types) do
        %w{integer decimal meter centimeter kilometer year month day hour second
          angle date time date_time cpf cnpj url email image attachment previous_field}
      end

      it { should validate_inclusion_of(:field_type).in_array(valid_types) }
    end

    context 'when field_type is previous_field' do
      subject { build(:field, field_type: 'previous_field') }
      it      { should validate_presence_of(:origin_field_id) }
    end
  end

  describe 'callbacks' do
    describe 'after_create: add_field_on_step' do
      let!(:step) { create(:step_type_form) }
      let(:field) { create(:field, step: step) }

      before { field }

      it "adds the correct key-value to Step's field_versions field" do
        expect(step.fields_versions[field.id.to_s]).to be_nil
      end

      it "updates step's user_id field with field's user_id" do
        expect(step.reload.user_id).to eq(field.user_id)
      end

      it "updates sets step's fields_versions with the correct key-value order of the step's fields" do
        step.fields.reload
        expect(step.fields_versions).to eq(step.fields.first.id.to_s => nil, step.fields.second.id.to_s => nil)
      end
    end
  end
end
