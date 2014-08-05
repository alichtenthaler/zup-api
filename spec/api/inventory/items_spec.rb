require "spec_helper"

describe Inventory::Items::API do
  let(:user) { create(:user) }

  context "POST /inventory/categories/:id/items" do
    let(:category) { create(:inventory_category_with_sections) }
    let(:status) { create(:inventory_status, category: category) }
    let(:valid_params) do
      JSON.parse <<-JSON
        {
          "inventory_status_id": #{status.id},
          "data": {}
        }
      JSON
    end

    it "creates the item object" do
      category.fields.each do |field|
        if field.kind == "text"
          valid_params['data'][field.id] = 'Test'
        else
          valid_params['data'][field.id] = 0.0
        end
      end

      post "/inventory/categories/#{category.id}/items", valid_params, auth(user)

      expect(response.status).to eq(201)
      expect(parsed_body).to include("message")

      expect(category.items.last).to_not be_nil
      expect(category.items.last.data).to_not be_empty
      expect(category.items.last.data.where(field: { kind: 'text' }).first.content).to eq("Test")
      expect(category.items.last.user).to_not be_nil
      expect(category.items.last.status).to eq(status)
    end

    it "creates the item object with images" do
      images_field_id = category.sections.last.fields.create(
        title: "Imagens",
        kind: "images",
        position: 0
      ).id

      fields = category.fields.order("id ASC")
      item_params = []

      fields.each do |field|
        unless field.kind == "images"
          valid_params['data'][field.id] = 'Rua do Banco'
        else
          valid_params['data'][field.id] = [
            {
              content: Base64.encode64(fixture_file_upload('images/valid_report_item_photo.jpg').read)
            },
            {
              content: Base64.encode64(fixture_file_upload('images/valid_report_item_photo.jpg').read)
            }
          ]
        end
      end

      post "/inventory/categories/#{category.id}/items", valid_params, auth(user)
      expect(response.status).to eq(201)
      body = parsed_body

      expect(body).to include("message")

      image_data = category.items.last.data.find_by(inventory_field_id: images_field_id)
      expect(category.items.last).to_not be_nil
      expect(category.items.last.data).to_not be_empty
      expect(image_data.content).to be_kind_of(Array)
      expect(category.items.last.user).to_not be_nil
    end

    it "doesn't allow to miss required fields" do
      category.fields.each do |field|
        valid_params['data'][field.id] = 'Test'
      end

      required_field = create(:inventory_field, section: category.sections.sample, required: true)
      last_item = category.items.last

      post "/inventory/categories/#{category.id}/items", valid_params, auth(user)
      expect(response.status).to eq(400)
      expect(parsed_body).to include("error")
      expect(category.items.reload.last).to eq(last_item)
    end

    it "accepts array as data" do
      category.fields.each do |field|
        valid_params['data'][field.id] = 'Test'
      end

      checkbox_field = create(:inventory_field, section: category.sections.sample, kind: 'checkbox')
      valid_params['data'][checkbox_field.id] = ['Test', 'Test2']

      last_item = category.items.last

      post "/inventory/categories/#{category.id}/items", valid_params, auth(user)
      expect(response.status).to eq(201)
      body = parsed_body

      expect(body).to include("message")

      checkbox_data = category.items.last.data.find_by(inventory_field_id: checkbox_field.id)
      expect(category.items.last).to_not be_nil
      expect(category.items.last.data).to_not be_empty
      expect(checkbox_data.content).to eq(['Test', 'Test2'])
      expect(category.items.last.user).to_not be_nil
    end
  end

  context "GET /inventory/categories/:cat_id/items/:id" do
    let(:category) { create(:inventory_category_with_sections) }
    let(:item) { create(:inventory_item) }

    it "returns the item info" do
      get "/inventory/categories/#{item.category.id}/items/#{item.id}",
          {}, auth(user)

      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include('item')
      expect(body['item']['id']).to eq(item.id)
      expect(body['item']['position']).to_not be_nil
    end

    it "returns the item with it's data" do
      get "/inventory/categories/#{item.category.id}/items/#{item.id}",
      {}, auth(user)

      expect(response.status).to eq(200)
      body = parsed_body

      item_data = body['item']
      expect(item_data).to include('data')
      expect(item_data['data']).to_not be_empty
      expect(item_data['data'].first['content']).to eq(item.data.first.content.to_s)
      expect(item_data['position']).to_not be_nil
      expect(item_data['position']['latitude']).to_not be_nil
      expect(item_data['position']['longitude']).to_not be_nil
    end
  end

  context "DELETE /inventory/categories/:cat_id/items/:id" do
    let(:category) { create(:inventory_category_with_sections) }
    let(:item) { create(:inventory_item) }

    it "destroys the item" do
      delete "/inventory/categories/#{item.category.id}/items/#{item.id}",
             {}, auth(user)

      expect(response.status).to eq(200)
      expect(Inventory::Item.find_by(id: item.id)).to be_nil
    end
  end

  context "PUT /inventory/categories/:id/items/:id" do
    let(:category) { create(:inventory_category_with_sections) }
    let(:item) { create(:inventory_item, category: category) }
    let(:item_data) { item.data.where(field: { kind: "text" }).last }
    let(:valid_params) do
      JSON.parse <<-JSON
        {
          "data": {}
        }
      JSON
    end

    it "updates the item object" do
      valid_params['data'][item_data.field.id] = 'Test'

      put "/inventory/categories/#{category.id}/items/#{item.id}", valid_params, auth(user)
      expect(response.status).to eq(200)
      expect(parsed_body).to include("message")
      item_data.reload
      expect(item_data.content).to eq('Test')
    end

    context "updating status" do
      let(:status) { create(:inventory_status, category: category) }
      let(:valid_params) do
        JSON.parse <<-JSON
          {
            "inventory_status_id": #{status.id}
          }
        JSON
      end

      it "updates the item status" do
        put "/inventory/categories/#{category.id}/items/#{item.id}", valid_params, auth(user)
        expect(response.status).to eq(200)
        expect(item.reload.status).to eq(status)
      end
    end
  end

  context "GET /inventory/categories/:id/items" do
    let!(:category) { create(:inventory_category_with_sections) }
    let!(:items) { create_list(:inventory_item, 5, category: category) }
    let(:category_params) do
      JSON.parse <<-JSON
        {
          "inventory_category_id": #{category.id}
        }
      JSON
    end

    context "param as array" do
      let(:other_category) { create(:inventory_category_with_sections) }
      let!(:other_items) { create_list(:inventory_item, 2, category: other_category) }

      it "accepts array as argument of inventory categories" do
        category_params["inventory_category_id"] = [category.id, other_category.id]
        get "/inventory/items", category_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body["items"].size).to eq(7)
      end
    end

    context "pagination" do
      let(:valid_params) do
        JSON.parse <<-JSON
          {
            "per_page": 2
          }
        JSON
      end

      it "returns the correct number of records on 'per_page'" do
        get "/inventory/items", valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body["items"].size).to eq(2)
      end

      it "returns all inventory items paginated" do
        valid_params['page'] = 2
        get "/inventory/items", valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body["items"].size).to eq(2)
        expect(
          body["items"].map do |item|
            item['id']
          end
        ).to_not eq(items[0..1].map(&:id))
      end

      it "return all inventory items ordenated and paginated" do
        get '/inventory/items?page=2&per_page=3&sort=id&order=desc',
            nil, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include('items')
        expect(body['items'].size).to eq(2)
        expect(body['items'][0]['id']).to eq(items[1].id)
      end
    end

    context "without filters" do
      it "returns all items from a category" do
        get "/inventory/items", category_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include("items")
        expect(body["items"].size).to eq(5)
      end
    end

    # Commenting for now, because this will change
    #context "searching by fields" do
    #  let!(:category_for_search) { create(:inventory_category_with_sections) }
    #  let(:valid_params) do
    #    @item, @item2 = items.sample(2)
    #    item_data = @item.data.first
    #    item_data2 = @item2.data.first

    #    JSON.parse <<-JSON
    #      {
    #        "filters": [{
    #          "field_id": #{item_data.inventory_field_id},
    #          "content": "#{item_data.content}"
    #        }, {
    #          "field_id": #{item_data2.inventory_field_id},
    #          "content": "#{item_data2.content}"
    #        }]
    #      }
    #    JSON
    #  end

    #  it "returns all items satisfying the search" do
    #    get "/inventory/items", valid_params.merge({
    #      category_id: category_for_search.id
    #    }), auth(user)
    #    expect(response.status).to eq(200)
    #    body = parsed_body

    #    expect(body).to include("items")
    #    expect(body["items"].map { |item| item["id"] }).to match_array([@item.id, @item2.id])
    #  end
    #end

    context "empty results" do
      let(:category_without_items) { create(:inventory_category) }

      it "retuns empty array" do
        get "/inventory/items",
            { inventory_category_id: category_without_items.id }, auth(user)

        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include("items")
        expect(body["items"].size).to eq(0)
      end
    end

    context "search by position" do
      let(:empty_category) { create(:inventory_category) }
      let(:valid_params) do
        JSON.parse <<-JSON
          {
            "position": {
              "latitude": "-23.5989650",
              "longitude": "-46.6836310",
              "distance": 1000
            }
          }
        JSON
      end

      it "returns closer item positions when passed position arg" do
        # Creating items
        points_nearby = [
          [-23.5989650, -46.6836310],
          [-23.5989340, -46.6835700],
          [-23.5981840, -46.6842480],
          [-23.5986170, -46.6828580]
        ]

        points_distant = [
          [Faker::Geolocation.lat, Faker::Geolocation.lng],
          [Faker::Geolocation.lat, Faker::Geolocation.lng],
          [Faker::Geolocation.lat, Faker::Geolocation.lng],
          [Faker::Geolocation.lat, Faker::Geolocation.lng]
        ]

        latitude_field, longitude_field = nil

        empty_category.fields.location.each do |field|
          if field.title == "latitude"
            latitude_field = field.id
          elsif field.title == "longitude"
            longitude_field = field.id
          end
        end

        nearby_items = points_nearby.map do |latlng|
          Inventory::CreateItemFromCategoryForm.new(
            category: empty_category,
            user: user,
            data: {
                    latitude_field => latlng[0],
                    longitude_field => latlng[1]
                  }
          ).create!
        end

        distant_items = points_distant.map do |latlng|
          Inventory::CreateItemFromCategoryForm.new(
            category: empty_category,
            user: user,
            data: {
                    latitude_field => latlng[0],
                    longitude_field => latlng[1]
                  }
          ).create!
        end

        expect(empty_category.items.count).to eq(8)
        expect(empty_category.items.map(&:position)).to_not include(nil)

        get "/inventory/items",
            valid_params.merge(inventory_category_id: empty_category.id), auth(user)

        expect(response.status).to eq(200)
        body = parsed_body

        expect(body["items"].map { |i| i["id"] }).to match_array(nearby_items.map { |i| i["id"] })
      end
    end
  end
end
