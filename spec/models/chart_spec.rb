require 'app_helper'

describe Chart do
  context 'dates validation' do
    context 'valid dates' do
      it 'passes the validation' do
        chart = build(:chart)
        chart.begin_date = Time.now
        chart.end_date = 5.days.from_now

        expect(chart).to be_valid
      end
    end

    context 'invalid dates' do
      it "doesn't passes the validation" do
        chart = build(:chart,
                      begin_date: Time.now,
                      end_date: 5.days.ago)

        expect(chart).to_not be_valid
        expect(chart.errors).to include(:begin_date)
      end
    end

    context 'no date at all' do
      it "doesn't passes the validation without the validity error" do
        business_report = build(:business_report, :without_dates)
        chart = build(:chart, business_report: business_report)

        chart.begin_date = chart.end_date = nil

        expect(chart).to_not be_valid
        expect(chart.errors).to include(:begin_date, :end_date)
      end
    end
  end

  describe '#processed?' do
    let(:chart) { build(:chart) }

    it 'returns true if data is populated' do
      chart.update(data: { any: 'data' })
      expect(chart.processed?).to be_truthy
    end

    it "returns false if data isn't populated" do
      expect(chart.processed?).to be_falsy
    end
  end
end
