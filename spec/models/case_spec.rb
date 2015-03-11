require 'rails_helper'

describe Case do
  context 'validations' do
    it { should validate_presence_of(:created_by_id) }
    it { should validate_presence_of(:initial_flow_id) }
  end

  context 'when change initial_flow_id' do
    let(:flow)  { create(:flow) }
    let(:step)  { create(:step_type_form, flow: flow) }
    let!(:kase) { create(:case, initial_flow: flow) }

    before do
      @kase = kase.reload
      @kase.initial_flow_id = 123456789
      @kase.valid?
    end

    it { expect(@kase).to_not be_valid }
    it { expect(@kase.errors.messages).to eql({initial_flow: [I18n.t('errors.messages.changed')]}) }
  end
end
