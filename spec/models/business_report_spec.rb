require 'app_helper'

describe BusinessReport do
  context 'dates validation' do
    context 'valid dates' do
      it 'passes the validation' do
        business_report = build(:chart)
        business_report.begin_date = Time.now
        business_report.end_date = 5.days.from_now

        expect(business_report.valid?).to be_truthy
      end
    end

    context 'invalid dates' do
      it "doesn't passes the validation" do
        business_report = build(:chart)
        business_report.begin_date = Time.now
        business_report.end_date = 5.days.ago

        expect(business_report.valid?).to be_falsy
        expect(business_report.errors).to include(:begin_date)
      end
    end
  end
end
