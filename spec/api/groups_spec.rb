require "spec_helper"

describe Groups::API do
  let!(:user) { create(:user) }

  context "POST /groups" do
    let(:valid_params) do
      JSON.parse <<-JSON
        {
          "name": "Cool group",
          "permissions": {
            "view_categories": false,
            "view_sections": true,
            "manage_inventory_categories": true,
            "groups_can_edit": [1, 2],
            "groups_can_view": [99]
          },
          "users": ["#{user.id}"]
        }
      JSON
    end

    it "needs authentication" do
      post "/groups", valid_params
      expect(response.status).to eq(401)
    end

    it "creates a group" do
      post "/groups", valid_params, auth(user)
      expect(response.status).to eq(201)
      body = parsed_body

      last_created_group = Group.last
      expect(last_created_group.name).to eq("Cool group")
      expect(last_created_group.view_categories).to eq(false)
      expect(last_created_group.view_sections).to eq(true)
      expect(last_created_group.manage_inventory_categories).to eq(true)
      expect(last_created_group.groups_can_edit).to match_array([1,2])
      expect(last_created_group.groups_can_view).to match_array([99])
      expect(last_created_group.users).to include(user)

      expect(body).to include("message")
      expect(body).to include("group")
      expect(body["group"]["name"]).to eq("Cool group")
      expect(body["group"]["permissions"]["groups_can_edit"]).to match_array([1, 2])
      expect(body["group"]["permissions"]["groups_can_view"]).to match_array([99])
    end

    it "can create a group without users" do
      valid_params.delete("users")
      post "/groups", valid_params, auth(user)
      expect(response.status).to eq(201)
      body = parsed_body

      last_created_group = Group.last
      expect(last_created_group.name).to eq("Cool group")
      expect(last_created_group.view_categories).to eq(false)
      expect(last_created_group.users).to be_empty

      expect(body).to include("message")
      expect(body).to include("group")
      expect(body["group"]["name"]).to eq("Cool group")
      expect(body["group"]["permissions"]["groups_can_edit"]).to be_kind_of(Array)
    end
  end

  context "GET /groups/:id" do
    let(:group) { create(:group) }

    it "returns group's data" do
      get "/groups/#{group.id}"
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include("group")
      expect(body["group"]["id"]).to eq(group.id)
    end

    it "returns group's users if display_users is true" do
      get "/groups/#{group.id}?display_users=true"
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include("group")
      expect(body["group"]["id"]).to eq(group.id)
      expect(body["group"]["users"]).to_not be_nil
    end

    it "returns status 404 and error message if group is not found" do
      get "/groups/12313123"
      expect(response.status).to eq(404)
      body = parsed_body
      expect(body).to include("error")
    end
  end

  context "DELETE /groups/:id" do
    let(:user) { create(:user) }
    let(:group) { create(:group) }

    it "delete the group" do
      delete "/groups/#{group.id}", nil, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body
      expect(body).to include("message")
      expect(Group.find_by(id: group.id)).to be_nil
    end
  end

  context "PUT /groups/:id" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:group) { create(:group, users: [user]) }
    let(:valid_params) do
      JSON.parse <<-JSON
        {
          "name": "An awesome name!",
          "users": [#{other_user.id}]
        }
      JSON
    end

    it "changes the group data" do
      put "/groups/#{group.id}", valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body
      expect(body).to include("message")

      changed_group = Group.find(group.id)
      expect(changed_group.name).to eq("An awesome name!")
      expect(changed_group.users).to include(other_user, user)
      expect(changed_group.users.count).to eq(2)
    end
  end

  context "POST /groups/:id/users" do
    let!(:user) { create(:user) }
    let(:group) { create(:group) }
    let(:valid_params) do
      JSON.parse <<-JSON
        {
          "user_id": #{user.id}
        }
      JSON
    end

    it "adds the user to the group" do
      post "/groups/#{group.id}/users", valid_params, auth(user)
      expect(response.status).to eq(201)
      expect(group.users).to include(user)
    end
  end

  context "DELETE /groups/:id/users" do
    let!(:user) { create(:user) }
    let(:group) { create(:group) }
    let(:valid_params) do
      JSON.parse <<-JSON
        {
          "user_id": #{user.id}
        }
      JSON
    end

    it "adds the user to the group" do
      delete "/groups/#{group.id}/users", valid_params, auth(user)
      expect(response.status).to eq(200)
      expect(group.users).to_not include(user)
    end
  end

  context "GET /groups" do
    let(:user) { create(:user) }
    let!(:member) { create(:user, name: "Smithers") }
    let!(:group) { create(:group, name: 'Great group') }
    let!(:groups) { create_list(:group, 20) }
    let(:valid_params) do
      JSON.parse <<-JSON
        {
          "name": "great"
        }
      JSON
    end

    it "return all groups if no filter is given" do
      get "/groups", nil, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include("groups")
      groups.map(&:id).each do |group_id|
        expect(
          body["groups"].map { |g| g['id'] }
        ).to include(group_id)
      end
    end

    it "return all groups with 'Great' on the name" do
      get "/groups", valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include("groups")
      expect(body["groups"].first["id"]).to eq(group.id)
    end

    it "return all groups with the member name" do
      valid_params.delete("name")
      valid_params["user_name"] = member.name

      group.users << member
      group.save

      get "/groups", valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include("groups")
      expect(body["groups"].last["id"]).to eq(group.id)
    end
  end

  context "GET /groups/:id/users" do
    let(:group) { create(:group) }
    let(:users) { create_list(:user, 5) }
    let(:wrong_users) { create_list(:user, 3) }

    it "returns all group users" do
      group.user_ids = users.map(&:id)
      group.save

      get "/groups/#{group.id}/users", nil, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      users.each(&:reload)

      expect(body).to include("group")
      expect(body).to include("users")
      expect(body["users"].size).to eq(5)
      expect(body["users"]).to eq(
        JSON.parse(User::Entity.represent(users, display_type: 'full').to_json)
      )
    end
  end

  context "PUT /groups/:id/permissions" do
    let(:group) { create(:group) }

    context "boolean permission" do
      let(:valid_params) do
        JSON.parse <<-JSON
        {
          "manage_users": true,
          "manage_groups": true
        }
        JSON
      end

      it "updates the group permission" do
        expect(group.manage_users).to eq(false)
        put "/groups/#{group.id}/permissions", valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include("group")
        group.reload
        expect(group.manage_users).to eq(true)
        expect(body['group']['permissions']).to_not be_empty
      end
    end

    context "array permission" do
      let(:valid_params) do
        JSON.parse <<-JSON
        {
          "inventory_categories_can_view": [1,2,3,4],
          "inventory_categories_can_edit": [1,3,5,6]
        }
        JSON
      end

      it "updates the group permission" do
        expect(group.inventory_categories_can_view).to eq([])
        expect(group.inventory_categories_can_edit).to eq([])

        put "/groups/#{group.id}/permissions", valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include("group")
        group.reload
        expect(group.inventory_categories_can_view).to eq([1,2,3,4])
        expect(group.inventory_categories_can_edit).to eq([1,3,5,6])

        expect(body['group']['permissions']).to_not be_empty
      end
    end
  end
end
