require 'rails_helper'

describe Reports::SerializeToWebhook do
  let!(:report) do
    create(:reports_item)
  end
  let!(:comments) do
    create_list(:reports_comment, 3, item: report)
  end

  subject { described_class.new(report) }

  describe '#serialize' do
    it 'serializes correctly the report info' do
      data = subject.serialize

      expect(data).to match(
        latitude: report.position.latitude,
        longitude: report.position.longitude,
        description: report.description,
        address: report.address,
        reference: report.reference,
        images: report.images,
        uuid: report.uuid,
        comments: an_instance_of(Array),
        status: {
          name: report.status.title
        },
        user: an_instance_of(Hash)
      )
    end
  end
end
