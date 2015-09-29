require 'app_helper'

describe Webhook do
  subject { described_class }

  describe '#find_category_by_title' do
    context 'passing an existent category' do
      context 'exactly' do
        let(:category_title) { 'Coleta Seletiva/PEV' }

        it 'returns the correct object on the hash' do
          expect(subject.find_category_by_title(category_title)).to_not be_nil
        end
      end

      context 'different case' do
        let(:category_title) { 'Coleta seletiva/pev' }

        it 'returns the correct object on the hash' do
          expect(subject.find_category_by_title(category_title)).to_not be_nil
        end
      end
    end
  end
end
