require 'spec_helper'

describe Reports::GetStats do
  let!(:report_category) { create(:reports_category_with_statuses) }
  let!(:status) { report_category.statuses.where(initial: false).first }

  context 'returning the correct stats' do
    let!(:reports) do
      create_list(:reports_item, 7, category: report_category, status: status)
    end

    subject { described_class.new(report_category.id) }

    it 'returns the count of every status on category' do
      returned_stats = subject.fetch

      expect(returned_stats.size).to eq(1)
      expect(returned_stats.first[:statuses].size).to eq(report_category.statuses.count)

      returned_count = returned_stats.first[:statuses].select do |s|
        s[:status_id] == status.id
      end.first[:count]

      expect(returned_count).to eq(7)
    end

    it 'accepts argument as array' do
      returned_stats = described_class.new([report_category.id]).fetch

      expect(returned_stats.size).to eq(1)
      expect(returned_stats.first[:statuses].size).to eq(report_category.statuses.count)

      returned_count = returned_stats.first[:statuses].select do |s|
        s[:status_id] == status.id
      end.first[:count]

      expect(returned_count).to eq(7)
    end

    context 'category with subcategories' do
      let!(:subcategory) do
        create(:reports_category_with_statuses, parent_category: report_category)
      end
      let!(:status) do
        subcategory.statuses.where(initial: false).first
      end

      before do
        create_list(:reports_item, 7, category: subcategory, status: status)
      end

      it 'return the right count' do
        returned_stats = subject.fetch

        expect(returned_stats.size).to eq(1)
        expect(returned_stats.first[:statuses].size).to eq(report_category.statuses.count)

        returned_count = returned_stats.first[:statuses].select do |s|
          s[:title] == status.title
        end.first[:count]

        expect(returned_count).to eq(14)
      end
    end
  end

  context 'filtering by date' do
    let!(:reports) do
      reports = create_list(
        :reports_item, 5,
        category: report_category,
        status: status
      )

      reports.each do |report|
        report.update(created_at: DateTime.new(2014, 1, 10))
      end
    end
    let!(:wrong_reports) do
      create_list(
        :reports_item, 10,
        category: report_category,
        status: status
      )
    end
    let(:begin_date) { Date.new(2014, 1, 9).iso8601 }
    let(:end_date) { Date.new(2014, 1, 13).iso8601 }

    it 'the desired reports on the right date range' do
      returned_stats = described_class.new(report_category.id,         begin_date: begin_date,
        end_date: end_date).fetch

      expect(returned_stats.first[:statuses].first[:count]).to eq(reports.size)
    end
  end
end
