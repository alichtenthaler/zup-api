module Groups
  class API < Grape::API
    resources :groups do
      mount Groups::Permissions::API

      desc 'List all groups'
      params do
        optional :name, type: String, desc: 'Name of the group'
        optional :user_name, type: String, desc: 'Name of the user'
        optional :display_users, type: Boolean, desc: 'Sets if should display users or not'
      end
      get do
        authenticate!
        validate_permission!(:view, Group)

        search_params = safe_params.permit(:name, :user_name)

        user_name = search_params.delete(:user_name)
        group_name = search_params.delete(:name)

        search_query = {}

        groups = Group.eager_load(:users, :permission)

        if group_name
          search_query = search_query.merge(name: group_name)
        end

        if user_name
          search_query = search_query.merge(users: { name: user_name })
        end

        # Find a way to remove these ugly permissions checking:
        unless user_permissions.can?(:manage, Group) ||
          current_user.permissions.inventories_categories_edit.any? ||
          current_user.permissions.reports_categories_edit.any? ||
          current_user.permissions.reports_items_forward.any? ||
          current_user.permissions.reports_items_edit.any? ||
          current_user.permissions.inventories_full_access ||
          current_user.permissions.reports_full_access
          groups = groups.where(groups: { id: user_permissions.groups_visible })
        end

        unless search_query.blank?
          groups = groups.fuzzy_search(search_query, false)
        end

        options = { display_users: safe_params[:display_users], only: return_fields }
        options[:display_type] = 'full' unless params[:return_only]

        {
          groups: Group::Entity.represent(
            groups,
            options
          )
        }
      end

      desc 'Create a group'
      params do
        requires :name, type: String, desc: "Group's name"
        optional :permissions, type: Hash, desc: "Group's permissions (add_users, view_categories, view_sections)"
        optional :description, type: String, desc: "Group's description"
        optional :users, type: Array, desc: 'Array of users id to add to the user'
      end
      post do
        authenticate!
        validate_permission!(:create, Group)

        group_params = safe_params.permit(:name, :description)
        permission_params = safe_params[:permissions].permit! if safe_params[:permissions]

        group = Group.create!(group_params)

        if safe_params[:users].present?
          users = User.where(id: safe_params[:users].map(&:to_i))
          group.users = users
        end

        if permission_params
          permission_params.each do |key, value|
            permission_params[key] = value.map(&:to_i) if value.is_a?(Array)
          end
        end

        group.build_permission(permission_params)
        group.save!

        { message: 'Group created successfully', group: Group::Entity.represent(group) }
      end

      desc 'Shows group info'
      params do
        optional :display_users, type: Boolean, desc: 'Sets if should display all group users or not'
      end
      get ':id' do
        group = Group.find_by!(id: safe_params[:id])
        validate_permission!(:view, group)

        if group
          {
            group: Group::Entity.represent(
              group, display_users: safe_params[:display_users])
          }
        else
          error!('Group not found', 404)
        end
      end

      desc 'Destroy group'
      delete ':id' do
        authenticate!

        group = Group.find_by(id: safe_params[:id])
        validate_permission!(:delete, group)

        if group && group.destroy
          { message: 'Group destroyed sucessfully' }
        else
          error!('Group not found', 404)
        end
      end

      desc "Update group's info"
      params do
        optional :name, type: String, desc: "Group's name"
        optional :description, type: String, desc: "Group's description"
        optional :permissions, type: Hash, desc: "Group's permissions (add_users, view_categories, view_sections)"
        optional :users, type: Array, desc: 'Array of users id to add to the user'
      end
      put ':id' do
        authenticate!
        group = Group.find(safe_params[:id])
        validate_permission!(:edit, group)

        group.name = safe_params[:name] if safe_params[:name]
        group.description = safe_params[:description] if safe_params[:description]
        permission_params = safe_params[:permissions].permit! if safe_params[:permissions]

        if safe_params[:users].present?
          users = User.where(id: safe_params[:users].map(&:to_i))
          group.users << users
        end

        unless permission_params.blank?
          permission_params.each do |key, value|
            permission_params[key] = value.map(&:to_i) if value.is_a?(Array)
          end

          group.permission.update(permission_params)
        end

        if group.save
          { message: 'Group updated succesfully', group: group }
        else
          error!('Group not found', 404)
        end
      end

      desc "Updates group's permissions"
      params do
        # Managing
        optional :users_full_access, type: Boolean, desc: 'Can manage users'
        optional :groups_full_access, type: Boolean, desc: 'Can manage groups'
        optional :inventories_full_access, type: Boolean, desc: 'Can inventory categories'
        optional :reports_full_access, type: Boolean, desc: 'Can manage inventory categories'
        optional :manage_flows, type: Boolean, desc: 'Can manage flows'
        optional :inventories_formulas_full_access, type: Boolean, desc: 'Can manage formulas'

        # Flows
        optional :flow_can_view_all_steps, type: Array[Integer],
                 desc: 'Flow ids that can be viewed by the group'
        optional :flow_can_execute_all_steps, type: Array[Integer],
                 desc: 'Flow ids that can be executed by the group'
        optional :flow_can_delete_own_cases, type: Array[Integer],
                 desc: 'Flow ids that can be delete by the group'
        optional :flow_can_delete_all_cases, type: Array[Integer],
                 desc: 'Flow ids that can be delete by the group'

        # Steps
        optional :can_view_step, type: Array[Integer],
                 desc: 'Step ids that can be viewed by the group'
        optional :can_execute_step, type: Array[Integer],
                 desc: 'Step ids that can be executed by the group'

        # Panel access
        optional :panel_access, type: Boolean, desc: 'Can access panel'
        optional :create_reports_from_panel, type: Boolean, desc: 'Can create reports while on panel'

        # Groups
        optional :groups_edit, type: Array[Integer],
                 desc: 'Groups ids that can be edited by the group'
        optional :groups_read_only, type: Array[Integer],
                 desc: 'Groups ids that can be viewed by the group'

        # Reports Categories
        optional :reports_categories_edit, type: Array[Integer],
                 desc: 'Reports categories ids that can be edited by the group'

        # Inventory Categories
        optional :inventories_categories_edit, type: Array[Integer],
                 desc: 'Inventory categories ids that can be edited by the group'

        # Inventory Items
        optional :inventories_items_read_only, type: Array[Integer],
                 desc: 'Inventory categories ids that group can see and view items'
        optional :inventories_items_create, type: Array[Integer],
                 desc: 'Inventory categories ids that group can create items'
        optional :inventories_items_edit, type: Array[Integer],
                 desc: 'Inventory categories ids that group can edit items'
        optional :inventories_items_delete, type: Array[Integer],
                 desc: 'Inventory categories ids that group can delete items'

        # Reports Items
        optional :reports_items_read_public, type: Array[Integer],
                 desc: 'Reports categories ids that group can see and view items'
        optional :reports_items_create, type: Array[Integer],
                 desc: 'Reports categories ids that group can create items'
        optional :reports_items_edit, type: Array[Integer],
                 desc: 'Reports categories ids that group can edit items'
        optional :reports_items_delete, type: Array[Integer],
                 desc: 'Reports categories ids that group can delete items'

        # Inventory Sections
        optional :inventory_sections_can_view, type: Array[Integer],
                 desc: 'Inventory sections ids that can be edited by the group'
        optional :inventory_sections_can_edit, type: Array[Integer],
                 desc: 'Inventory sections ids that can be edited by the group'

        # Inventory Fields
        optional :inventory_fields_can_view, type: Array[Integer],
                 desc: 'Inventory fields ids that can be edited by the group'
        optional :inventory_fields_can_edit, type: Array[Integer],
                 desc: 'Inventory fields ids that can be edited by the group'
      end
      put ':id/permissions' do
        authenticate!
        group = Group.find(params[:id])
        validate_permission!(:edit, group)

        permission_params = safe_params.permit(
          :users_full_access,           :inventories_full_access,
          :groups_full_access,          :manage_reports_categories,
          :reports_full_access,
          :manage_flows,
          :inventories_formulas_full_access,
          :create_reports_from_panel,   :panel_access,
          groups_edit: [],
          inventory_sections_can_view: [], inventory_sections_can_edit: [],
          inventory_categories_can_view: [], inventory_categories_can_edit: [],
          inventory_fields_can_view: [], inventory_fields_can_edit: [],
          groups_read_only: [],             reports_categories_edit: [],
          reports_categories_can_view: [], inventory_categories_edit: [],
          flow_can_execute_all_steps: [], flow_can_delete_own_cases: [],
          step_view_all_case: [],          step_execute_all_case: [],
          inventories_items_read_only: [],
          inventories_items_edit: [],
          inventories_items_create: [],
          inventories_items_delete: [],
          reports_items_read_public: [],
          reports_items_edit: [],
          reports_items_create: [],
          reports_items_delete: []
        )

        unless permission_params.empty?
          group.permission.update(permission_params)
        end

        { group: Group::Entity.represent(group) }
      end

      desc 'Add user to group'
      params do
        requires :user_id, type: Integer, desc: 'The user id you will add'
      end
      post ':id/users' do
        authenticate!

        group = Group.find(safe_params[:id])
        validate_permission!(:edit, group)
        group.users << User.find(safe_params[:user_id])
        group.save!

        { message: 'User added successfully' }
      end

      desc 'Removes user from group'
      params do
        requires :user_id, type: Integer, desc: 'The user you will remove from group'
      end
      delete ':id/users' do
        authenticate!

        group = Group.find(safe_params[:id])
        validate_permission!(:edit, group)
        group.users.delete(User.find(safe_params[:user_id]))
        group.save!

        { message: 'User delete successfully' }
      end

      desc 'List users from group'
      paginate per_page: 25
      get ':id/users' do
        authenticate!

        group = Group.find(safe_params[:id])
        validate_permission!(:view, group)

        {
          group: Group::Entity.represent(group),
          users: User::Entity.represent(
            paginate(group.users.distinct),
            display_type: 'full'
          )
        }
      end
    end
  end
end
