require "spec_helper"

describe Search::Reports::Items::API do
  let(:user) { create(:user) }

  describe "GET /search/reports/:category_id/status/:status_id/items" do
    let(:category) { create(:reports_category_with_statuses) }
    let(:items) do
      create_list(:reports_item, 5, category: category) end

    let(:valid_params) do
      JSON.parse <<-JSON
        {
          "address": "Abilio"
        }
      JSON
    end

    it "returns the specified items" do
      desired_item = items.sample
      status = category.statuses.sample
      desired_item.update!(address: "Rua Abilio Soares", status: status)

      get "/search/reports/#{category.id}/status/#{status.id}/items",
        valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      reports_ids = body['reports'].map do |r|
        r['id']
      end

      expect(reports_ids).to include(desired_item.id)
      items.delete(desired_item)
      expect(reports_ids).to_not include(items.map(&:id))
    end
  end

  describe "GET /search/reports/items" do
    let(:category) { create(:reports_category_with_statuses) }

    context "specifing the fields" do
      let!(:items) { create_list(:reports_item, 3, category: category) }

      it "returns only specified fields" do
        get "/search/reports/items?return_fields=id,protocol,address,user.name&display_type=full", nil, auth(user)
        expect(response.status).to eq(200)

        body = parsed_body['reports']
        expect(body.first).to match(
          "id" => a_value,
          "protocol" => a_value,
          "address" => an_instance_of(String),
          "user" => {
            "name" => an_instance_of(String)
          }
        )
      end
    end

    context "sorting" do
      context "by user name" do
        let!(:users) { create_list(:user, 5) }
        let!(:items) do
          users.map do |u|
            create(:reports_item, category: category, user: u)
          end
        end
        let!(:valid_params) do
          JSON.parse <<-JSON
            {
              "sort": "user_name",
              "order": "asc"
            }
          JSON
        end

        it "returns the items on the correct order" do
          get "/search/reports/items", valid_params, auth(user)

          returned_ids = parsed_body['reports'].map do |r|
            r['id']
          end

          expect(returned_ids).to eq(items.sort_by do |item|
            item.user.name.downcase
          end.map(&:id))
        end
      end
    end

    context "by categories" do
      let!(:items) do
        create_list(:reports_item, 3, category: category)
      end
      let!(:wrong_items) do
        other_category = create(:reports_category_with_statuses)
        create_list(:reports_item, 3, category: other_category)
      end
      let(:valid_params) do
        JSON.parse <<-JSON
          {
            "reports_categories_ids": #{category.id}
          }
        JSON
      end

      it "returns the correct items with the correct address" do
        get "/search/reports/items", valid_params, auth(user)

        returned_ids = parsed_body['reports'].map do |r|
          r['id']
        end

        expect(returned_ids).to match_array(items.map(&:id))
        expect(returned_ids).to_not match_array(wrong_items.map(&:id))
      end
    end

    context "by users" do
      context "only one user" do
        let(:user) { create(:user) }
        let!(:items) do
          create_list(:reports_item, 3, category: category, user: user)
        end
        let!(:wrong_items) do
          create_list(:reports_item, 3, category: category)
        end
        let(:valid_params) do
          JSON.parse <<-JSON
          {
            "users_ids": #{user.id}
          }
          JSON
        end

        it "returns the correct items from the correct user" do
          get "/search/reports/items", valid_params, auth(user)

          returned_ids = parsed_body['reports'].map do |r|
            r['id']
          end

          expect(returned_ids).to match_array(items.map(&:id))
          expect(returned_ids).to_not match_array(wrong_items.map(&:id))
        end
      end

      context "by multiple users" do
        let(:user) { create(:user) }
        let(:user2) { create(:user) }
        let!(:items) do
          other_category = create(:reports_category_with_statuses)
          create_list(:reports_item, 3, category: category, user: user) +
            create_list(:reports_item, 3, category: other_category, user: user)
        end
        let!(:wrong_items) do
          create_list(:reports_item, 3, category: category)
        end
        let(:valid_params) do
          JSON.parse <<-JSON
          {
            "users_ids": "#{user.id},#{user2.id}"
          }
          JSON
        end

        it "returns the correct items from the correct user" do
          get "/search/reports/items", valid_params, auth(user)

          returned_ids = parsed_body['reports'].map do |r|
            r['id']
          end

          expect(returned_ids).to match_array(items.map(&:id))
          expect(returned_ids).to_not match_array(wrong_items.map(&:id))
        end
      end
    end


    context "by statuses" do
      let!(:items) do
        create_list(:reports_item, 3, category: category)
      end
      let!(:wrong_items) do
        new_status = create(:status)
        category.status_categories.create!(status: new_status)

        items = create_list(:reports_item, 3, category: category)
        items.each do |item|
          Reports::UpdateItemStatus.new(item).update_status!(new_status)
        end

        items
      end
      let(:valid_params) do
        JSON.parse <<-JSON
          {
            "statuses_ids": "#{items.first.reports_status_id}"
          }
        JSON
      end

      it "returns the correct items with the correct address" do
        get "/search/reports/items", valid_params, auth(user)

        returned_ids = parsed_body['reports'].map do |r|
          r['id']
        end

        expect(returned_ids).to match_array(items.map(&:id))
        expect(returned_ids).to_not match_array(wrong_items.map(&:id))
      end
    end

    context "by address" do
      let(:items) do
        create_list(:reports_item, 3, category: category)
      end
      let(:valid_params) do
        JSON.parse <<-JSON
          {
            "address": "abilio"
          }
        JSON
      end

      it "returns the correct items with the correct address" do
        correct_item = items.sample
        correct_item.update(address: 'Rua Abilio Soares, 140')

        get "/search/reports/items", valid_params, auth(user)
        expect(parsed_body['reports'].first['id']).to eq(correct_item.id)
      end
    end

    context "by overdue" do
      let(:items) do
        create_list(:reports_item, 3, category: category)
      end
      let(:valid_params) do
        JSON.parse <<-JSON
          {
            "overdue": true
          }
        JSON
      end

      it "returns the correct items with the correct address" do
        correct_item = items.sample
        correct_item.update(overdue: true)

        get "/search/reports/items", valid_params, auth(user)
        expect(parsed_body['reports'].map { |r| r['id'] }).to eq([correct_item.id])
      end
    end

    context "by query" do
      let!(:items) do
        create_list(:reports_item, 10, category: category)
      end
      let!(:correct_items) do
        user = create(:user, name: "crazybar")
        item = items.sample
        items.delete(item)
        item.update(user_id: user.id)

        item2 = items.sample
        items.delete(item2)
        item2.update(address: "crazybar do naldo")

        [item, item2]
      end
      let(:valid_params) do
        JSON.parse <<-JSON
          {
            "query": "crazybar"
          }
        JSON
      end

      it "returns the correct items with the correct address" do
        get "/search/reports/items", valid_params, auth(user)
        expect(parsed_body['reports'].map do |r|
          r['id']
        end).to match_array(correct_items.map(&:id))
      end
    end

    context "by address or position" do
      let(:items) do
        create_list(:reports_item, 3, category: category)
      end
      let(:latitude) { -23.5505200 }
      let(:longitude) { -46.6333090 }
      let(:valid_params) do
        JSON.parse <<-JSON
          {
            "address": "abilio",
            "position": {
              "latitude": #{latitude},
              "longitude": #{longitude},
              "distance": 1000
            }
          }
        JSON
      end

      it "returns the correct items with address, position or both" do
        items.each do |item|
          item.update(
            position: Reports::Item.rgeo_factory.point(-1, 0)
          )
        end

        correct_item_1 = items.first
        correct_item_1.update(address: 'Rua Abilio Soares, 140')

        correct_item_2 = items.last
        correct_item_2.update(
          position: Reports::Item.rgeo_factory.point(longitude, latitude)
        )

        get "/search/reports/items", valid_params, auth(user)
        expect(parsed_body['reports'].map do
          |r| r['id']
        end).to match_array([correct_item_1.id, correct_item_2.id])
      end
    end

    context "with clusterization active" do
      let(:items) do
        create_list(:reports_item, 3, category: category)
      end
      let(:latitude) { -23.5505200 }
      let(:longitude) { -46.6333090 }
      let(:valid_params) do
        JSON.parse <<-JSON
          {
            "position": {
              "latitude": #{latitude},
              "longitude": #{longitude},
              "distance": 1000
            },
            "clusterize": true,
            "zoom": 13
          }
        JSON
      end

      before do
        items.each do |item|
          item.update(
            position: Reports::Item.rgeo_factory.point(longitude, latitude)
          )
        end
      end

      it "returns clusterized options" do
        get "/search/reports/items", valid_params, auth(user)
        body = parsed_body

        expect(body['clusters'].size).to eq(1)
        expect(response.header['Total']).to eq('3')

        cluster = body['clusters'].first

        expect(cluster['position']).to_not be_empty
        expect(cluster['count']).to eq(3)
        expect(cluster['category_id']).to be_present
      end
    end
  end
end
