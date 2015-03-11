require "spec_helper"

describe Reports::CreateHistoryEntry do
  let(:item) { create(:reports_item) }
  let(:user) { create(:user) }

  subject { described_class.new(item, user) }

  describe "#create" do
    context "with the status changed" do
      let(:status) { create(:status) }
      let(:kind) { 'changed' }
      let(:action) { "Mudou o status do relato" }

      it "creates the history entry" do
        subject.create(kind, action, status)

        entry = Reports::ItemHistory.find_by(
          kind: kind,
          action: action,
          user_id: user.id,
          reports_item_id: item.id
        )

        expect(entry).to_not be_nil
        expect(entry.objects).to match_array([status])
      end
    end

    context "with the category changed" do
      let(:category) { create(:reports_category) }
      let(:kind) { 'changed' }
      let(:action) { "Mudou a categoria do relato" }

      it "creates the history entry" do
        subject.create(kind, action, category)

        entry = Reports::ItemHistory.find_by(
          kind: kind,
          action: action,
          user_id: user.id,
          reports_item_id: item.id
        )

        expect(entry).to_not be_nil
        expect(entry.objects).to match_array([category])
      end
    end
  end
end
