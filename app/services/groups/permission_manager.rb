module Groups
  class PermissionManager
    attr_reader :group, :permissions

    def initialize(group)
      @group = group
      @permissions = group.permission.reload
    end

    def fetch
      data = []

      GroupPermission::TYPES.each do |permission_type, permission_names|
        objects_permissions = {}

        permission_names.each do |name, klass|
          if klass == Array
            permissions.send(name).each do |object_id|
              objects_permissions[object_id] ||= []
              objects_permissions[object_id] << name
            end
          elsif permissions.send(name)
            data << {
              permission_type: permission_type,
              permission_names: name
            }
          end
        end

        objects_permissions.each do |object_id, names|
          klass = GroupPermission::TYPES_CLASSES[permission_type]

          if klass
            object = klass.find_by(id: object_id)

            if object
              data << {
                permission_type: permission_type,
                object: klass::Entity.represent(object),
                permission_names: names.uniq
              }
            end
          end
        end
      end

      data
    end

    def add_with_objects(permission_name, objects_ids)
      validate_permission_name(permission_name)
      validate_objects_existence(permission_name, objects_ids)

      permissions.atomic_cat(permission_name, objects_ids)
    end

    def remove_with_objects(permission_name, objects_ids)
      validate_permission_name(permission_name)

      objects_ids.each do |id|
        permissions.atomic_remove(permission_name, id)
      end
    end

    def add(permission_name)
      validate_permission_name(permission_name)

      permissions.update(permission_name => true)
    end

    def remove(permission_name)
      validate_permission_name(permission_name)

      permissions.update(permission_name => false)
    end

    private

    def validate_permission_name(permission_name)
      unless permissions.respond_to?(permission_name)
        fail "Permission doesn't exists: #{permission_name}"
      end
    end

    def validate_objects_existence(permission_name, objects_ids)
      if permission_name.to_s.start_with?('reports')
        klass = Reports::Category
      elsif permission_name.to_s.start_with?('inventories')
        klass = Inventory::Category
      elsif permission_name.to_s.start_with?('groups')
        klass = Group
      elsif permission_name.to_s.start_with?('users')
        klass = User
      elsif permission_name.to_s.start_with?('business_reports')
        klass = BusinessReport
      else
        return
      end

      objects_ids.each do |id|
        klass.find_by!(id: id)
      end
    end
  end
end
