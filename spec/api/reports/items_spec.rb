require 'spec_helper'

describe Reports::Items::API do
  let(:user) { create(:user) }
  let(:category) { create(:reports_category_with_statuses) }
  let(:valid_params) do
    {
        latitude: Faker::Geolocation.lat,
        longitude: Faker::Geolocation.lng,
        address: 'Fake Street, 1234',
        reference: 'Close to the store',
        description: 'The situation is really crappy around here.',
        images: [
            Base64.encode64(fixture_file_upload('images/valid_report_item_photo.jpg').read),
            Base64.encode64(fixture_file_upload('images/valid_report_item_photo.jpg').read)
        ]
    }
  end

  context 'POST /reports/:category_id/items' do
    it 'should create a new report with lat/long and address' do
      post '/reports/' + category.id.to_s + '/items', valid_params, auth(user)
      expect(response.status).to eq(201)
      body = parsed_body['report']

      expect(body['id']).to_not be_nil
      expect(body['address']).to eq(valid_params[:address])
      expect(body['reference']).to eq(valid_params[:reference])
      expect(body['description']).to eq(valid_params[:description])
      expect(body['position']['latitude']).to eq(valid_params[:latitude])
      expect(body['position']['longitude']).to eq(valid_params[:longitude])
      expect(body['status']['id']).to_not be_nil
      expect(body['status']['title']).to_not be_nil
      expect(body['status']['color']).to_not be_nil
      expect(body['status']['final']).to_not be_nil
      expect(body['status']['initial']).to_not be_nil

      expect(body['images'][0]['high']).to_not be_empty
      expect(body['images'][0]['low']).to_not be_empty
      expect(body['images'][1]['high']).to_not be_empty
      expect(body['images'][1]['low']).to_not be_empty
    end

    it 'should create a new report when an inventory item is given' do
      inventory_item = create(:inventory_item)
      valid_params_for_report_with_inventory_item = {
          inventory_item_id: inventory_item.id
      }.merge(valid_params.except(:latitude, :longitude, :address))

      post '/reports/' + category.id.to_s + '/items', valid_params_for_report_with_inventory_item, auth(user)
      body = parsed_body['report']
      expect(body['id']).to_not be_nil
      expect(body['address']).to eq(inventory_item.location[:address])
      expect(body['description']).to eq(valid_params[:description])
      expect(body['position']['latitude']).to eq(inventory_item.location[:latitude])
      expect(body['position']['longitude']).to eq(inventory_item.location[:longitude])
      expect(body['status']['id']).to_not be_nil
      expect(body['status']['title']).to_not be_nil
      expect(body['status']['color']).to_not be_nil
      expect(body['status']['final']).to_not be_nil
      expect(body['status']['initial']).to_not be_nil

      # TODO: Fix these validations
      # expect(body['images'][0]['url']).to eq('/uploads/' + valid_params[:images][0].original_filename)
      # expect(body['images'][1]['url']).to eq('/uploads/' + valid_params[:images][1].original_filename)
    end

    it "create a new report with uploaded images instead of encoded ones" do
      valid_params[:images] = [
        fixture_file_upload('images/valid_report_item_photo.jpg'),
        fixture_file_upload('images/valid_report_item_photo.jpg')
      ]

      post '/reports/' + category.id.to_s + '/items', valid_params, auth(user)
      expect(response.status).to eq(201)
      body = parsed_body['report']

      expect(body['id']).to_not be_nil
      expect(body['address']).to eq(valid_params[:address])
      expect(body['reference']).to eq(valid_params[:reference])
      expect(body['description']).to eq(valid_params[:description])
      expect(body['position']['latitude']).to eq(valid_params[:latitude])
      expect(body['position']['longitude']).to eq(valid_params[:longitude])
      expect(body['status']['id']).to_not be_nil
      expect(body['status']['title']).to_not be_nil
      expect(body['status']['color']).to_not be_nil
      expect(body['status']['final']).to_not be_nil
      expect(body['status']['initial']).to_not be_nil
      expect(body['category']).to_not be_nil
      expect(body['images'][0]['high']).to_not be_empty
      expect(body['images'][0]['low']).to_not be_empty
      expect(body['images'][1]['high']).to_not be_empty
      expect(body['images'][1]['low']).to_not be_empty
    end

    it "accepts passing an user_id as argument" do
      other_user = create(:user)
      valid_params[:user_id] = other_user.id

      post "/reports/#{category.id}/items", valid_params, auth(user)
      expect(response.status).to eq(201)
      expect(category.reports.last.user).to eq(other_user)
      expect(category.reports.last.reporter).to eq(user)
    end

    it "creates a confidential report" do
      valid_params[:confidential] = true

      post "/reports/#{category.id}/items", valid_params, auth(user)
      expect(response.status).to eq(201)
      expect(category.reports.last.confidential).to be_truthy
    end

    context "from panel" do
      subject do
        post "/reports/#{category.id}/items", valid_params, auth(user)
      end

      context "user has permission to create from panel" do
        it "allows creation of the report" do
          valid_params[:from_panel] = true
          subject

          expect(response.status).to eq(201)
        end
      end

      context "user doesn't have permission to create from panel" do
        before do
          GroupPermission.where(group_id: user.groups.pluck(:id)).update_all(create_reports_from_panel: false, manage_reports: false)
        end

        it "disallows creation of the report" do
          valid_params[:from_panel] = true
          subject

          expect(response.status).to_not eq(201)
        end
      end
    end
  end

  context 'PUT /reports/:category_id/items/:id' do
    let(:existent_item) { create(:reports_item_with_images, category: category) }

    it 'updates an existent report' do
      put "/reports/#{category.id.to_s}/items/#{existent_item.id}",
          valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body['report']

      expect(body['id']).to_not be_nil
      expect(body['address']).to eq(valid_params[:address])
      expect(body['reference']).to eq(valid_params[:reference])
      expect(body['description']).to eq(valid_params[:description])
      expect(body['position']['latitude']).to eq(valid_params[:latitude])
      expect(body['position']['longitude']).to eq(valid_params[:longitude])
      expect(body['status']['id']).to_not be_nil
      expect(body['status']['title']).to_not be_nil
      expect(body['status']['color']).to_not be_nil
      expect(body['status']['final']).to_not be_nil
      expect(body['status']['initial']).to_not be_nil
    end

    it 'is able to change the images' do
      valid_params = {
        images: [{
          id: existent_item.images.first.id,
          file: Base64.encode64(fixture_file_upload('images/valid_report_category_marker.png').read)
        }]
      }

      old_image_url = existent_item.images.first.url
      old_image_url2 = existent_item.images.last.url

      put "/reports/#{category.id.to_s}/items/#{existent_item.id}", valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body['report']

      expect(existent_item.reload.images.first.url).to_not eq(old_image_url)
      expect(existent_item.reload.images.last.url).to eq(old_image_url2)
    end

    context "updating the status" do
      it "is able to update the status passing status_id" do
        status = category.statuses.final.first
        valid_params['status_id'] = status.id

        expect(existent_item.id).to_not eq(status.id)
        put "/reports/#{category.id.to_s}/items/#{existent_item.id}", valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body['report']
        expect(body['status']['id']).to eq(status.id)
      end

      context "when the status is private" do
        let(:status) { create(:status) }

        before do
          Reports::StatusCategory.create(
            category: category,
            status: status,
            private: true
          )

          allow(UserMailer).to receive(:notify_report_status_update).and_return(nil)
        end

        it "doesn't notify the user" do
          valid_params['status_id'] = \
            category.status_categories.private.first.status.id

          expect(existent_item.reports_status_id).to_not eq(status.id)
          put "/reports/#{category.id.to_s}/items/#{existent_item.id}", valid_params, auth(user)
          expect(response.status).to eq(200)
          body = parsed_body['report']
          expect(body['status']['id']).to eq(status.id)
          expect(UserMailer).to_not have_received(:notify_report_status_update)
        end
      end
    end

    it "is able to update the report category" do
      new_category = create(:reports_category_with_statuses)

      valid_params = {
        'category_id' => new_category.id
      }

      put "/reports/#{category.id.to_s}/items/#{existent_item.id}", valid_params, auth(user)
      expect(parsed_body['report']['category']['id']).to eq(new_category.id)
    end

    it "changes the param to confidential" do
      valid_params['confidential'] = true
      put "/reports/#{category.id.to_s}/items/#{existent_item.id}", valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body['report']
      expect(body['confidential']).to be_truthy
    end
  end

  context 'PUT /reports/:category_id/items/:id/change_category' do
    let(:item) { create(:reports_item_with_images, category: category) }
    let(:other_category) { create(:reports_category_with_statuses) }
    let(:other_status) do
      other_category.statuses.first
    end

    context "valid category and status" do
      let(:valid_params) do
        JSON.parse <<-JSON
          {
            "new_category_id": #{other_category.id},
            "new_status_id": #{other_status.id}
          }
        JSON
      end

      it "updates the category and status of the item correctly" do
        put "/reports/#{item.category.id}/items/#{item.id}/change_category", valid_params, auth(user)
        item.reload

        expect(item.category).to eq(other_category)
        expect(item.status).to eq(other_status)
      end
    end
  end


  context 'GET /reports/items' do
    context "no filters" do
      let!(:reports) do
        create_list(:reports_item_with_images, 20, category: category)
      end

      it "return all reports ordenated and paginated" do
        get '/reports/items?page=2&per_page=15&sort=id&order=asc',
            nil, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include("reports")
        expect(body['reports'].size).to eq(5)

        expect(
          body['reports'].map {|r| r['id'] }
        ).to match_array(reports[15..19].map(&:id))
      end

      it "returns inventory_categories on listing" do
        get '/reports/items', { display_type: 'full' }, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['reports'].first['inventory_categories']).to_not be_nil
      end
    end

    context "multiple inventory_item_id" do
      let!(:inventory_item) { create(:inventory_item) }
      let!(:reports) do
        create_list(:reports_item_with_images, 3, category: category)
      end
      let!(:reports_with_inventory_id) do
        create_list(:reports_item_with_images, 5,
                       category: category,
                       inventory_item_id: inventory_item.id)
      end

      it "returns only one report by inventory_item_id" do
        get '/reports/items', nil, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['reports'].size).to eq(4)

        reports_ids = body['reports'].map do |r|
          r['id']
        end
        expect(reports_ids).to include(*reports.map(&:id))
        expect((reports_ids - reports.map(&:id)).size).to eq(1)
      end
    end

    context "user filter" do
      let!(:reports) do
        create_list(
          :reports_item_with_images, 12,
          user: user, category: category
        )
      end
      let!(:wrong_reports) do
        create_list(
          :reports_item_with_images, 5,
          category: category
        )
      end
      let(:valid_params) do
        JSON.parse <<-JSON
          {
            "user_id": #{user.id}
          }
        JSON
      end

      it "returns all reports for user" do
        get '/reports/items', valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include("reports")
        expect(body['reports'].size).to eq(12)
        body['reports'].each do |r|
          expect(Reports::Item.find(r['id']).user_id).to eq(user.id)
        end
      end
    end

    context "category filter" do
      let!(:reports) do
        create_list(
          :reports_item_with_images, 16,
          category: category
        )
      end
      let!(:wrong_reports) do
        create_list(
          :reports_item_with_images, 5
        )
      end
      let(:valid_params) do
        JSON.parse <<-JSON
          {
            "category_id": #{category.id}
          }
        JSON
      end

      it "returns all reports for category" do
        get '/reports/items', valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include("reports")
        expect(body['reports'].size).to eq(16)
        body['reports'].each do |r|
          expect(r['category_id']).to eq(category.id)
        end
      end
    end

    context "date filter" do
      let!(:reports) do
        reports = create_list(
          :reports_item_with_images, 5,
        )

        reports.each do |report|
          report.update(created_at: DateTime.new(2014, 1, 10))
        end
      end
      let!(:wrong_reports) do
        create_list(
          :reports_item_with_images, 10
        )
      end
      let(:valid_params) do
        JSON.parse <<-JSON
          {
            "begin_date": "#{Date.new(2014, 1, 9).iso8601}",
            "end_date": "#{Date.new(2014, 1, 13).iso8601}"
          }
        JSON
      end

      it "returns all reports in the date range" do
        get '/reports/items', valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['reports'].size).to eq(reports.length)
        response_ids = body['reports'].map { |r| r['id'] }
        wrong_reports.each do |wrong_report|
          expect(wrong_report.id.in?(response_ids)).to eq(false)
        end
      end

      it "returns all reports even with one param" do
        valid_params.delete("begin_date")

        get '/reports/items', valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['reports'].size).to eq(5)
        expect(body['reports'].map { |r| r['id'] }).to match_array(reports.map(&:id))
      end
    end

    context "statuses filter" do
      let!(:status) { category.statuses.where(initial: false).first }
      let!(:reports) do
        create_list(
          :reports_item, 7,
          category: category,
          status: status
        )
      end
      let!(:wrong_reports) do
        create_list(
          :reports_item, 5,
          category: category
        )
      end
      let(:valid_params) do
        JSON.parse <<-JSON
          {
            "statuses": [#{status.id}]
          }
        JSON
      end

      it "returns all reports with correct statuses" do
        get "/reports/items", valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['reports'].size).to eq(reports.length)
        expect(body['reports'].map { |r| r['id'] }).to match_array(reports.map { |r| r.id })
      end

      it "accepts only one id as argument" do
        valid_params["statuses"] = status.id

        get "/reports/items", valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['reports'].size).to eq(reports.length)
        expected_ids = Set.new(reports.map { |r| r.id })
        expect(Set.new(body['reports'].map { |r| r['id'] })).to eq(expected_ids)
      end
    end

    context "multiple filters" do
      let!(:reports) do
        create_list(
          :reports_item_with_images, 11,
          category: category, user: user
        )
      end
      let!(:wrong_reports) do
        create_list(
          :reports_item_with_images, 5,
          category: category
        )
      end
      let(:valid_params) do
        JSON.parse <<-JSON
          {
            "category_id": #{category.id},
            "user_id": #{user.id}
          }
        JSON
      end

      it "returns all reports for category" do
        get '/reports/items', valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include("reports")
        expect(body['reports'].size).to eq(11)
        body['reports'].each do |r|
          expect(Reports::Item.find(r['id']).user_id).to eq(user.id)
        end
      end
    end

    context "guest group" do
      let(:other_category) { create(:reports_category_with_statuses) }
      let!(:reports) do
        create_list(
          :reports_item_with_images, 2,
          category: category, user: user
        )
      end
      let!(:wrong_reports) do
        create_list(
          :reports_item_with_images, 3,
          category: other_category
        )
      end

      before do
        Group.guest.each do |group|
          group.permission.reports_categories_can_view = [category.id]
          group.save!
        end
      end

      it "only can see the category it has the permission" do
        get "/reports/items"
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['reports'].size).to eq(2)
        expect(body['reports'].map do |i|
          i['id']
        end).to match_array(reports.map(&:id))
      end
    end
  end

  context 'GET /reports/items/:id' do
    let(:user) { create(:user) }
    let(:item) { create(:reports_item_with_images, :with_feedback) }

    it "returns the report data" do
      get "/reports/items/#{item.id}", nil
      expect(response.status).to eq(200)
      report = parsed_body['report']

      expect(report['id']).to_not be_nil
      expect(report['address']).to_not be_nil
      expect(report['description']).to_not be_nil
      expect(report['position']['latitude']).to_not be_nil
      expect(report['position']['latitude']).to_not be_nil
      expect(report['category_icon']).to_not be_nil
      expect(report['status']['id']).to_not be_nil
      expect(report['status']['title']).to_not be_nil
      expect(report['status']['color']).to_not be_nil
      expect(report['status']['final']).to_not be_nil
      expect(report['status']['initial']).to_not be_nil
      expect(report['category']).to_not be_nil
      expect(report['feedback']).to be_present
    end

    context "if the user that created is the same" do
      let(:item) { create(:reports_item_with_images, :with_feedback, user: user) }

      it "shows the protocol" do
        get "/reports/items/#{item.id}", nil, auth(user)
        expect(response.status).to eq(200)
        report = parsed_body['report']

        expect(report['protocol']).to_not be_blank
      end
    end

    context "if the user didn't create the item" do
      let(:item) { create(:reports_item_with_images) }

      before do
        user.groups = Group.guest
        user.save!
      end

      it "doesn't show the protocol" do
        get "/reports/items/#{item.id}", nil, auth(user)
        expect(response.status).to eq(200)
        report = parsed_body['report']

        expect(report['protocol']).to be_blank
      end
    end

    context "if the user has admin privileges" do
      let(:item) { create(:reports_item_with_images) }

      before do
        user.groups.first.permission.update(panel_access: true)
        user.save!
      end

      it "does show the protocol" do
        get "/reports/items/#{item.id}", nil, auth(user)
        expect(response.status).to eq(200)
        report = parsed_body['report']

        expect(report['protocol']).to_not be_blank
      end
    end
  end

  context 'DELETE /reports/items/:id' do
    let!(:item) { create(:reports_item_with_images) }

    it "removes a report item" do
      delete "/reports/items/#{item.id}", {}, auth(user)
      expect(response.status).to eq(204)

      expect { item.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'GET /reports/:category_id/items' do
    let!(:items) { create_list(:reports_item_with_images, 3, category: category) }

    it 'should retrieve a list of reports from a given category' do
      get '/reports/' + category.id.to_s + '/items'
      expect(response.status).to eq(200)
      body = parsed_body["reports"]

      expect(body.count).to eq(3)

      body.each do |report|
        expect(report['id']).to_not be_nil
        expect(report['address']).to_not be_nil
        expect(report['description']).to_not be_nil
        expect(report['position']['latitude']).to_not be_nil
        expect(report['position']['latitude']).to_not be_nil
        expect(report['status_id']).to_not be_nil
      end
    end

    context "search by position" do
      let(:empty_category) { create(:reports_category_with_statuses) }
      let(:valid_params) do
        JSON.parse <<-JSON
          {
            "category_id": #{empty_category.id},
            "position": {
              "latitude": "-23.5989650",
              "longitude": "-46.6836310",
              "distance": 1000
            }
          }
        JSON
      end

      it "returns closer report positions when passed position arg" do
        # Creating items
        points_nearby = [
          [-23.5989650, -46.6836310],
          [-23.5989340, -46.6835700],
          [-23.5981840, -46.6842480],
          [-23.5986170, -46.6828580]
        ]

        points_distant = [
          [-40.34, -12.3045],
          [-40.34, -12.3045],
          [-40.34, -12.3045],
          [-40.34, -12.3045]
        ]

        nearby_items = points_nearby.map do |latlng|
          create(
            :reports_item_with_images,
            position: RGeo::Geographic::simple_mercator_factory.point(latlng[1], latlng[0]),
            category: empty_category
          )
        end

        distant_items = points_distant.map do |latlng|
          create(
            :reports_item_with_images,
            position: RGeo::Geographic::simple_mercator_factory.point(latlng[1], latlng[0]),
            category: empty_category
          )
        end

        expect(empty_category.reports.count).to eq(8)
        expect(empty_category.reports.map(&:position)).to_not include(nil)

        get '/reports/items', valid_params

        expect(response.status).to eq(200)
        body = parsed_body

        expect(body["reports"].map { |i| i["id"] }).to match_array(nearby_items.map { |i| i["id"] })
      end
    end
  end

  context 'GET /reports/inventory/:invetory_item_id/items' do
    let(:inventory_item) { create(:inventory_item) }
    let!(:items) {
      create_list(:reports_item_with_images, 3,
                     category: category, inventory_item: inventory_item)
    }

    it 'should retrieve a list of reports from a given category' do
      get '/reports/inventory/' + inventory_item.id.to_s + '/items'
      expect(response.status).to eq(200)
      body = parsed_body["reports"]
      expect(body.count).to eq(3)

      body.each do |report|
        expect(report['id']).to_not be_nil
        expect(report['address']).to_not be_nil
        expect(report['description']).to_not be_nil
        expect(report['position']['latitude']).to_not be_nil
        expect(report['position']['longitude']).to_not be_nil
        expect(report['status_id']).to_not be_nil
      end
    end
  end

  context 'GET /reports/users/:user_id/items' do
    let!(:items) {
      create_list(:reports_item_with_images, 3,
                     category: category, user: user)
    }

    it 'should retrieve a list of reports from a given user' do
      get '/reports/users/' + user.id.to_s + '/items'
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body['reports'].count).to eq(3)

      body['reports'].each do |report|
        expect(report['id']).to_not be_nil
        expect(report['address']).to_not be_nil
        expect(report['description']).to_not be_nil
        expect(report['position']['latitude']).to_not be_nil
        expect(report['position']['longitude']).to_not be_nil
        expect(report['status']['id']).to_not be_nil
        expect(report['category']['id']).to_not be_nil
      end

      expect(body['total_reports_by_user']).to eq(3)
    end
  end

  context 'GET /reports/users/me/items' do
    let!(:items) {
      create_list(:reports_item_with_images, 3,
                     category: category, user: user)
    }

    it 'should retrieve a list of reports from the current user' do
      get '/reports/users/me/items?token=' + {}.auth(user)[:token]
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body['reports'].count).to eq(3)

      body['reports'].each do |report|
        expect(report['id']).to_not be_nil
        expect(report['address']).to_not be_nil
        expect(report['description']).to_not be_nil
        expect(report['position']['latitude']).to_not be_nil
        expect(report['position']['longitude']).to_not be_nil
        expect(report['status']['id']).to_not be_nil
        expect(report['status']['title']).to_not be_nil
        expect(report['status']['color']).to_not be_nil
        expect(report['status']['final']).to_not be_nil
        expect(report['status']['initial']).to_not be_nil
        expect(report['category']).to_not be_nil
      end

      expect(body['total_reports_by_user']).to eq(3)
    end
  end
end
