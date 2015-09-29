require 'app_helper'

describe BusinessReports::CompileDataForChart do
  let(:chart) { create(:chart) }
  let(:metric_class) do
    class DummyMetricClass < BusinessReports::Metrics::Base
    end
    DummyMetricClass
  end
  let(:dummy_result) do
    BusinessReports::ChartResult.new(
      ['Category', 'Total'],
      [
        ['Category 1', 34],
        ['Category 2', 20]
      ]
    )
  end

  before do
    allow_any_instance_of(metric_class).to receive(:fetch_data).and_return(dummy_result)
  end

  subject { described_class.new(chart, metric_class) }

  describe '#compile' do
    context 'valid chart' do
      it 'saves the correct `data` for the chart' do
        subject.compile!
        expect(chart.reload.data).to_not be_blank

        expect(chart.reload.data).to match(
          'subtitles' => ['Category', 'Total'],
          'content' =>  [
            ['Category 1', 34],
            ['Category 2', 20]
          ]
        )
      end
    end
  end

  describe '#guess_metric_class' do
    subject { described_class.new(chart) }
    it 'guesses the correct metric class' do
      expect(subject.guess_metric_class).to eq(BusinessReports::Metrics::TotalReportsByCategory)
    end
  end
end
