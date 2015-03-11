require "spec_helper"

describe Inventory::CreateHistoryEntry do
  let(:item) { create(:inventory_item) }
  let(:user) { create(:user) }

  subject { described_class.new(item, user) }

  describe "#create" do
    context "with a report created" do
      let(:report) { create(:reports_item) }
      let(:kind) { 'added' }
      let(:action) { "Criou uma solicitação para o item" }

      it "creates the history entry" do
        subject.create(kind, action, report)

        entry = Inventory::ItemHistory.find_by(
          kind: kind,
          action: action,
          user_id: user.id,
          inventory_item_id: item.id
        )

        expect(entry).to_not be_nil
        expect(entry.objects).to match_array([report])
      end
    end

    context "with images added" do
      let(:images) { create_list(:inventory_item_data_image, 3) }
      let(:kind) { 'added' }
      let(:action) { "Criou uma solicitação para o item" }

      it "creates the history entry" do
        subject.create(kind, action, images)

        entry = Inventory::ItemHistory.find_by(
          kind: kind,
          action: action,
          user_id: user.id,
          inventory_item_id: item.id
        )

        expect(entry).to_not be_nil
        expect(entry.objects).to match_array(images)
      end
    end
  end
end
