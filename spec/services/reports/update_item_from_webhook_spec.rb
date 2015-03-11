require "rails_helper"

describe Reports::UpdateItemFromWebhook do
  let!(:report) { create(:reports_item) }
  let!(:category) { report.category }

  subject { described_class.new(report, valid_params) }

  context "#update!" do
    let(:encoded_image) do
      Base64.encode64(fixture_file_upload('images/valid_report_item_photo.jpg').read).force_encoding(Encoding::UTF_8)
    end
    let(:valid_params) do
      {
        external_category_id: 3,
        is_report: true,
        is_solicitation: false,
        latitude: -13.12427698396538,
        longitude: -21.385812899349485,
        description: "Este é um relato de exemplo",
        address: "Av. Paulista, 130",
        reference: "Próximo à Gazeta",
        images: [
          { 'mime-type' => "image/png", data: encoded_image }
        ],
        status: {
          name: "Em andamento"
        },
        user: {
          email: "usuario@zup.com.br",
          name: "Usuário de Teste"
        },
        comments: [{
          user: {
            email: "admin@zup.com.br",
            name: "Administrador"
          },
          message: "Este é um comentário"
        }]
      }
    end

    it "creates the report item" do
      report = subject.update!

      expect(report.external_category_id).to eq(3)
      expect(report.is_solicitation).to be_falsy
      expect(report.is_report).to be_truthy
      expect(report.position.y).to eq(-13.12427698396538)
      expect(report.position.x).to eq(-21.385812899349485)

      comment = report.comments.last
      expect(comment.message).to eq("Este é um comentário")
      expect(comment.author.email).to eq("admin@zup.com.br")

      image = report.images.last
      expect(image).to_not be_nil

      status = report.status
      expect(status.title).to eq("Em andamento")
    end
  end
end
