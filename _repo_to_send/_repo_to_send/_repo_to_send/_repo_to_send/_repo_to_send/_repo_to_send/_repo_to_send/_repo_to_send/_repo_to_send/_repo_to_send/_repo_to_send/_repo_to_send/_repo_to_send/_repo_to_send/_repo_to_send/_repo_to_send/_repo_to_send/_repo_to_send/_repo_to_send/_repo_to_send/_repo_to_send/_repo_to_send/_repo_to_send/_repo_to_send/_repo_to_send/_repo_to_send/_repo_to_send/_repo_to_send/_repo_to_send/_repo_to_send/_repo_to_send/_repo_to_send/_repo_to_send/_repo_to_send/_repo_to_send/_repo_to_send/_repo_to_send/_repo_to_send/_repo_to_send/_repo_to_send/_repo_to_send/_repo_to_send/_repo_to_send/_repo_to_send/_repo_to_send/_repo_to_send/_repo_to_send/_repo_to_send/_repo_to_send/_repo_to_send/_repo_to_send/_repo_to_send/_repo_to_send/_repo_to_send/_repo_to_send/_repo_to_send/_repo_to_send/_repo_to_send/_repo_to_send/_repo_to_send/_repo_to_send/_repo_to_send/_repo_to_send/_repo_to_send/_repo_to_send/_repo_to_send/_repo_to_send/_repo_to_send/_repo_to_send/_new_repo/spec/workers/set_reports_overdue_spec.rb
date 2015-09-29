require 'app_helper'

describe SetReportsOverdue do
  let(:category) { create(:reports_category_with_statuses, resolution_time: 2.days.to_i) }
  let(:already_marked_as_overdue_reports) { create_list(:reports_item, 2, :overdue) }
  let(:overdue_reports) { create_list(:reports_item, 2, category: category) }
  let(:not_overdue_reports) { create_list(:reports_item, 2, category: category) }

  before do
    overdue_reports.each do |item|
      item.update(created_at: 3.days.ago)
      item.status_history.last.update(created_at: 3.days.ago)
    end

    not_overdue_reports.each do |item|
      item.update(created_at: 1.day.ago)
      item.status_history.last.update(created_at: 1.day.ago)
    end
  end

  subject { described_class.new.perform }

  describe '#perform' do
    it 'set overdue reports as overdue' do
      subject
      overdue_reports.each(&:reload)

      overdue_reports.each do |item|
        expect(item).to be_overdue
      end

      not_overdue_reports.each do |item|
        expect(item).to_not be_overdue
      end

      already_marked_as_overdue_reports.each do |item|
        expect(item).to be_overdue
      end
    end
  end
end
