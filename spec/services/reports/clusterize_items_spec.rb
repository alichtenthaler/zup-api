require "spec_helper"

describe Reports::ClusterizeItems do

  context "items with similar positions" do
    let(:category) { create(:reports_category_with_statuses) }
    let!(:items) do
      create_list(:reports_item, 10, category: category)
    end

    subject { described_class.new(Reports::Item.scoped, 3) }

    it "returns only one cluster" do
      expect(subject.results[:clusters].size).to eq(1)
      expect(subject.results[:reports].size).to eq(0)

      clusters_count = subject.results[:clusters].inject(0) { |n, cluster| n + cluster.count }
      expect(clusters_count).to eq(10)
    end
  end

end
