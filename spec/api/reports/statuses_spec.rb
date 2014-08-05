require "spec_helper"

describe Reports::Statuses::API do
  let(:user) { create(:user) }
  let(:category) { create(:reports_category_with_statuses) }

  describe "GET /reports/categories/:category_id/statuses" do
    before do
      get "/reports/categories/#{category.id}/statuses", nil, auth(user)
    end

    it "returns all the category's statuses" do
      expect(parsed_body['statuses'].map do |s|
        s['id']
      end).to match_array(category.statuses.map(&:id))
    end
  end

  describe "POST /reports/categories/:category_id/statuses"  do
    context "with valid params do" do
      let(:valid_params) do
        JSON.parse <<-JSON
          {
            "title": "Test status",
            "color": "#440033",
            "initial": true,
            "final": false,
            "active": false
          }
        JSON
      end

      before do
        post "/reports/categories/#{category.id}/statuses", valid_params, auth(user)
      end

      it "creates the new status" do
        created_status = category.statuses.where(title: valid_params['title']).first

        expect(response.status).to eq(201)

        status = valid_params
        expect(created_status.title).to eq(status['title'])
        expect(created_status.color).to eq(status['color'])
        expect(created_status.initial).to eq(status['initial'])
        expect(created_status.final).to eq(status['final'])
        expect(created_status.active).to eq(status['active'])
      end
    end
  end

  describe "PUT /reports/categories/:category_id/statuses/:id"  do
    let!(:status) { create(:status, categories: [category]) }
    context "with valid params do" do
      let(:valid_params) do
        JSON.parse <<-JSON
          {
            "title": "Test status",
            "color": "#440033",
            "initial": true,
            "final": false,
            "active": false
          }
        JSON
      end

      before do
        put "/reports/categories/#{category.id}/statuses/#{status.id}", valid_params, auth(user)
      end

      it "creates the new status" do
        created_status = category.statuses.where(title: valid_params['title']).first

        expect(response.status).to eq(200)

        status = valid_params
        expect(created_status.title).to eq(status['title'])
        expect(created_status.color).to eq(status['color'])
        expect(created_status.initial).to eq(status['initial'])
        expect(created_status.final).to eq(status['final'])
        expect(created_status.active).to eq(status['active'])
      end
    end
  end

  describe "DELETE /reports/categories/:category_id/statuses/:id"  do
    let!(:status) { create(:status, categories: [category]) }

    before do
      delete "/reports/categories/#{category.id}/statuses/#{status.id}", {}, auth(user)
    end

    it "deletes the status" do
      expect(response.status).to eq(200)
      expect(Reports::Status.find_by(id: status.id)).to be_nil
    end
  end

end
