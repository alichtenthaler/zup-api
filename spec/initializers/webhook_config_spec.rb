require 'app_helper'

describe Webhook do
  subject { described_class }

  before do
    Webhook.load_categories_from_file(
      File.join(Application.config.root, 'spec', 'support', 'webhook_categories.yml')
    )
  end

  describe '#find_category_by_title' do
    context 'passing an existent category' do
      context 'exactly' do
        let(:category_title) { 'Solicitação/colocação de contêineres' }

        it 'returns the correct object on the hash' do
          expect(subject.find_category_by_title(category_title)).to_not be_nil
        end
      end

      context 'different case' do
        let(:category_title) { 'SOLICITAÇÃO/COLOCAÇÃO DE CONTÊINERES' }

        it 'returns the correct object on the hash' do
          expect(subject.find_category_by_title(category_title)).to_not be_nil
        end
      end
    end
  end
end
