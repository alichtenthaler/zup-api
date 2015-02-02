require "spec_helper"

describe Reports::Item do
  context "validations" do
    it "should not allow description" do
      report = build(:reports_item)
      report.description = "a" * 801

      expect(report.save).to eq(false)
      expect(report.errors).to include(:description)
    end
  end

  it "has relationship with inventory category through category" do
    inventory_categories = create_list(:inventory_category, 3)
    category = create(
      :reports_category_with_statuses,
      inventory_category_ids: inventory_categories.map(&:id)
    )
    item = create(:reports_item, category: category)

    expect(item.inventory_categories).to eq(inventory_categories)
  end

  it "has the same position of the inventory item" do
    inventory_item = create(:inventory_item)
    report = build(:reports_item)

    report.inventory_item = inventory_item
    expect(report.save).to eq(true)
    expect(report.position).to eq(inventory_item.position)
  end

  context "status history" do
    it "create a new entry on status history when status is created" do
      item = create(:reports_item)
      new_status = item.statuses.last
      Reports::UpdateItemStatus.new(item).set_status(new_status)

      expect(item.save!).to eq(true)
      expect(item.status_history.reload.size).to eq(2)
      expect(item.status_history.last.new_status).to eq(new_status)
    end
  end

  describe "#can_receive_feedback?" do
    let(:report) { create(:reports_item) }

    it "returns true if the report is final and the time isn't expired" do
      Reports::UpdateItemStatus.new(report).update_status!(report.category.statuses.final.first)
      expect(report.can_receive_feedback?).to eq(true)
    end

    it "returns false if the report category doesn't accept feedback" do
      report.category.update!(user_response_time: nil)
      expect(report.can_receive_feedback?).to eq(false)
    end

    it "returns false if the report is final but the time expired" do
      Reports::UpdateItemStatus.new(report).update_status!(report.category.statuses.final.first)
      report.status_history
            .last
            .update!(
              created_at: \
                Time.now - report.category.user_response_time.seconds - 1.day
            )

      expect(report.can_receive_feedback?).to eq(false)
    end
  end
end

