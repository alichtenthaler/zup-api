module Groups::Permissions
  class API < Base::API
    helpers do
      def load_group(group_id = params[:group_id])
        Group.find(group_id)
      end
    end

    route_param :group_id do
      namespace :permissions do
        desc 'Return all permissions, by type and object'
        get do
          authenticate!

          group = load_group

          validate_permission!(:view, group)

          permissions = Groups::PermissionManager.new(group)
          permissions.fetch
        end

        desc 'Add permissions to a group'
        params do
          optional :objects_ids, type: Array,
                  desc: 'Array of ids of the object type'
          requires :permissions, type: Array,
                  desc: 'Array of permission names'
        end
        post ':permissions_type' do
          authenticate!

          group = load_group

          validate_permission!(:edit, group)

          permissions = Groups::PermissionManager.new(group)

          permissions_type = params[:permissions_type].to_sym
          params[:permissions].each do |permission_name|
            permission_class = GroupPermission::TYPES[permissions_type][permission_name]
            next unless permission_class

            if permission_class == Array
              objects_ids = params[:objects_ids].map(&:to_i)
              permissions.add_with_objects(permission_name, objects_ids)
            elsif permission_class == GroupPermission::Boolean
              permissions.add(permission_name)
            end
          end

          {
            message: 'Permissões atualizadas com sucesso.'
          }
        end

        desc 'Remove permissions from a group'
        params do
          requires :permission, type: String,
                   desc: 'Permission name'
          optional :object_id, type: Integer,
                   desc: 'The object id to remove from'
        end
        delete ':permissions_type' do
          authenticate!

          group = load_group

          validate_permission!(:edit, group)

          permissions = Groups::PermissionManager.new(group)

          permissions_type = params[:permissions_type].to_sym
          permission_name = params[:permission]
          permission_class = GroupPermission::TYPES[permissions_type][permission_name]

          if permission_class == Array
            object_id = params[:object_id].to_i
            permissions.remove_with_objects(permission_name, [object_id])
          elsif permission_class == GroupPermission::Boolean
            permissions.remove(permission_name)
          end

          {
            message: 'Permissão removida com sucesso.'
          }
        end
      end
    end
  end
end
