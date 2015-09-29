require 'app_helper'

describe BusinessReports::Charts::API do
  let(:user) { create(:user) }
  let(:business_report) { create(:business_report) }

  describe 'GET /business_reports/1/charts' do
    let!(:charts) do
      create_list(:chart, 3, business_report: business_report)
    end

    subject { get "/business_reports/#{business_report.id}/charts", nil, auth(user) }

    it 'lists all metric report charts' do
      subject
      expect(response.status).to be_a_success_request

      charts.each do |chart|
        expect(parsed_body).to include_an_entity_of(chart)
      end
    end
  end

  describe 'POST /business_reports/1/charts' do
    let(:params) do
      {
        title: 'Gráfico',
        description: 'Descrição de gráfico',
        chart_type: 'pie',
        metric: 'total-reports-by-category',
        categories_ids: [1, 2, 3],
        begin_date: Date.new(2015, 6, 1),
        end_date: Date.new(2015, 6, 30)
      }
    end

    subject { post "/business_reports/#{business_report.id}/charts", params, auth(user) }

    it 'creates a new metric report' do
      subject

      expect(response.status).to be_a_requisition_created
      created_chart = business_report.charts.last

      expect(created_chart.title).to eq(params[:title])
      expect(created_chart.description).to eq(params[:description])
      expect(created_chart.metric).to eq(params[:metric])
      expect(created_chart.categories_ids).to eq(params[:categories_ids])
    end
  end

  describe 'PUT /business_reports/1/charts/1' do
    let(:chart) { create(:chart, business_report: business_report) }
    let(:params) do
      {
        title: 'Gráfico modificado',
        description: 'Descrição de gráfico modificado',
        metric: 'total-reports-by-category',
        chart_type: 'pie',
        begin_date: Date.new(2015, 6, 1),
        end_date: Date.new(2015, 6, 30)
      }
    end

    subject { put "/business_reports/#{business_report.id}/charts/#{chart.id}", params, auth(user) }

    it 'updates an existing metric report' do
      subject

      expect(response.status).to be_a_success_request

      chart = parsed_body
      expect(chart['title']).to eq(params[:title])
      expect(chart['description']).to eq(params[:description])
      expect(chart['metric']).to eq(params[:metric])
      expect(chart['chart_type']).to eq(params[:chart_type])
      expect(Date.parse(chart['begin_date'])).to eq(params[:begin_date])
      expect(Date.parse(chart['end_date'])).to eq(params[:end_date])
    end
  end

  describe 'DELETE /business_reports/1/charts/1' do
    let(:chart) { create(:chart, business_report: business_report) }

    subject { delete "/business_reports/#{business_report.id}/charts/#{chart.id}", nil, auth(user) }

    it 'deletes an existing metric report' do
      subject

      expect(response.status).to be_a_success_request
      expect(Chart.find_by(id: chart.id)).to be_nil
    end
  end
end
