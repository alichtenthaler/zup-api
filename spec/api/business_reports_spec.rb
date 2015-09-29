require 'app_helper'

describe BusinessReports::API do
  let(:user) { create(:user) }

  describe 'GET /business_reports' do
    let!(:business_reports) do
      create_list(:business_report, 3)
    end

    subject { get '/business_reports', nil, auth(user) }

    it 'lists all metric reports' do
      subject
      expect(response.status).to be_a_success_request

      business_reports.each do |br|
        expect(parsed_body).to include_an_entity_of(br)
      end
    end
  end

  describe 'GET /business_reports/:id' do
    let(:business_report) { create(:business_report) }

    subject { get "/business_reports/#{business_report.id}", nil, auth(user) }

    it 'returns the business report json' do
      subject
      expect(response.status).to be_a_success_request

      expect(parsed_body).to be_an_entity_of(business_report)
    end
  end

  describe 'GET /business_reports/:id/export/xls' do
    let(:business_report) { create(:business_report) }

    subject { get "/business_reports/#{business_report.id}/export/xls", nil, auth(user) }

    it 'returns the business report xls' do
      subject
      expect(response.status).to be_a_success_request
    end
  end

  describe 'POST /business_reports' do
    let(:params) do
      {
        title: 'Relatório',
        summary: 'Descrição do relatório',
        begin_date: Date.new(2015, 6, 1),
        end_date: Date.new(2015, 6, 30)
      }
    end

    subject { post '/business_reports', params, auth(user) }

    it 'creates a new metric report' do
      subject

      expect(response.status).to be_a_requisition_created
    end

    context 'without permission' do
      let(:group) { create(:group) }

      before do
        user.groups = [group]
        user.save!
      end

      it "can't create the business report" do
        subject
        expect(response.status).to be_a_forbidden
      end
    end
  end

  describe 'PUT /business_reports/:id' do
    let(:business_report) { create(:business_report) }
    let(:params) do
      {
        title: 'Relatório',
        summary: 'Descrição do relatório',
        begin_date: Date.new(2015, 6, 1),
        end_date: Date.new(2015, 6, 30)
      }
    end

    subject { put "/business_reports/#{business_report.id}", params, auth(user) }

    it 'updates an existing metric report' do
      subject

      expect(response.status).to be_a_success_request

      br = parsed_body
      expect(br['title']).to eq(params[:title])
      expect(br['summary']).to eq(params[:summary])
      expect(Date.parse(br['begin_date'])).to eq(params[:begin_date])
      expect(Date.parse(br['end_date'])).to eq(params[:end_date])
    end
  end

  describe 'DELETE /business_reports/:id' do
    let(:business_report) { create(:business_report) }

    subject { delete "/business_reports/#{business_report.id}", nil, auth(user) }

    it 'deletes an existing metric report' do
      subject

      expect(response.status).to be_a_success_request
      expect(BusinessReport.find_by(id: business_report.id)).to be_nil
    end
  end
end
