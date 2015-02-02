require "spec_helper"

describe Reports::UpdateItemStatus do
  subject { described_class.new(item) }
  let(:category) { create(:reports_category_with_statuses) }
  let(:status) { create(:status) }

  before do
    Reports::StatusCategory.create(
      status: status,
      category: category
    )
  end

  describe "#set_status" do
    let(:item) { create(:reports_item, category: category) }

    it "sets the item status to given status" do
      subject.set_status(status)
      expect(item.status).to eq(status)
    end

    it "builds a new history entry for status" do
      subject.set_status(status)
      expect(item.status_history.last.new_status).to eq(status)
    end
  end

  describe "#update_status!" do
    let(:item) { create(:reports_item, category: category) }

    context "valid status from same category" do
      it "updates the item's status" do
        subject.update_status!(status)

        item.reload
        expect(item.status).to eq(status)
      end
    end

    context "valid status with no relation with the company" do
      let(:different_status) { create(:status) }

      it "raises an error" do
        expect {
          subject.update_status!(different_status)
        }.to raise_error(/Status doesn't belongs to category/)
      end
    end
  end
end
