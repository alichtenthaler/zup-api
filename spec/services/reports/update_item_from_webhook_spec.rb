require 'rails_helper'

describe Reports::UpdateItemFromWebhook do
  let!(:report) { create(:reports_item) }
  let!(:category) { report.category }
  let!(:other_category) do
    create(:reports_category_with_statuses, title: 'Solicitação/colocação de contêineres')
  end

  subject { described_class.new(report, valid_params) }

  context '#update!' do
    context 'changing status and adding comment' do
      let(:encoded_image) do
        Base64.encode64(fixture_file_upload('images/valid_report_item_photo.jpg').read).force_encoding(Encoding::UTF_8)
      end
      let(:valid_params) do
        {
          external_category_id: 100,
          status: {
            name: 'Finalizado'
          },
          comments: [{
            user: {
              email: 'admin@zup.com.br',
              name: 'Administrador'
            },
            message: 'Este relato está finalizado'
          }]
        }
      end

      it 'updates the report item' do
        report = subject.update!
        report.reload

        expect(report.category).to eq(other_category)

        comment = report.comments.last
        expect(comment.message).to eq('Este relato está finalizado')
        expect(comment.author.email).to eq('admin@zup.com.br')

        status = report.status
        expect(status.title).to eq('Finalizado')
      end
    end
  end
end
