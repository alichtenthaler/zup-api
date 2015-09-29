require 'spec_helper'

describe FetchDataForChart do
  let!(:chart) { create(:chart) }

  describe '#perform' do
    it 'compiles data chart for the chart' do
      service_double = double('business_reports__compile_data_for_chart')
      expect(BusinessReports::CompileDataForChart).to receive(:new).with(chart).and_return(service_double)
      expect(service_double).to receive(:compile!)

      FetchDataForChart.new.perform(chart.id)
    end

    it 'doesnt raise an error if the chart isnt found' do
      expect do
        FetchDataForChart.new.perform('fake-id')
      end.to_not raise_error
    end
  end
end
