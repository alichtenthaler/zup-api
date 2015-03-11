require "rails_helper"

describe Groups::Permissions::API do
  let(:user) { create(:user) }
  let(:group) { create(:group) }

  context "GET /groups/:id/permissions" do
    let(:inventory_category) { create(:inventory_category) }

    before do
      group.permission.update(
        inventory_categories_can_edit: [inventory_category.id],
        inventory_categories_can_view: [inventory_category.id],
        manage_reports: true
      )
    end

    it "returns all permissions by type and id" do
      get "/groups/#{group.id}/permissions", nil, auth(user)
      expect(response.status).to eq(200)

      expect(parsed_body.size).to eq(2)
      expect(parsed_body.first["permission_type"]).to eq("inventory")
      expect(parsed_body.last["permission_type"]).to eq("report")
    end
  end

  context "POST /groups/:id/permissions/:type" do
    let(:type) { 'report' }
    let(:url) { "/groups/#{group.id}/permissions/#{type}" }

    context 'array permissions' do
      let(:objects_ids) { [1,2] }
      let(:permissions) { ['reports_categories_can_edit', 'reports_categories_can_view'] }

      let(:valid_params) do
        {
          objects_ids: objects_ids,
          permissions: permissions
        }
      end

      it "adds the ids to the array of ids of the permissions" do
        post url, valid_params, auth(user)
        expect(response.status).to eq(201)

        group.permission.reload
        expect(group.permission.reports_categories_can_edit).to match_array([1,2])
        expect(group.permission.reports_categories_can_view).to match_array([1,2])
      end
    end

    context 'boolean permissions' do
      let(:permissions) { ['manage_reports', 'manage_reports_categories'] }

      let(:valid_params) do
        {
          permissions: permissions
        }
      end

      it "sets the permissions as true" do
        post url, valid_params, auth(user)
        expect(response.status).to eq(201)

        group.permission.reload
        expect(group.permission.manage_reports).to be_truthy
        expect(group.permission.manage_reports_categories).to be_truthy
      end
    end
  end

  context "DELETE /groups/:id/permissions/:type" do
    let(:type) { 'report' }
    let(:url) { "/groups/#{group.id}/permissions/#{type}" }

    context 'permission with object id' do
      let(:object_id) { 1 }
      let(:permission) { 'reports_categories_can_edit' }

      let(:valid_params) do
        {
          object_id: object_id,
          permission: permission
        }
      end

      before do
        group.permission.update(
          permission => [object_id]
        )
      end

      it "removes the id from the permission" do
        delete url, valid_params, auth(user)
        expect(response.status).to eq(200)

        group.permission.reload
        expect(group.permission.reports_categories_can_edit).to_not include(object_id)
      end
    end

    context 'boolean permissions' do
      let(:permissions) { ['manage_reports', 'manage_reports_categories'] }

      let(:valid_params) do
        {
          permissions: permissions
        }
      end

      it "sets the permissions as true" do
        post url, valid_params, auth(user)
        expect(response.status).to eq(201)

        group.permission.reload
        expect(group.permission.manage_reports).to be_truthy
        expect(group.permission.manage_reports_categories).to be_truthy
      end
    end
  end

end
