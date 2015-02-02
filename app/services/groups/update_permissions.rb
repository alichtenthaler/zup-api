module Groups
  class UpdatePermissions

    def self.update(groups, object, permission_name)

      if groups && groups.any?
        # Remove permission of groups
        Group.that_includes_permission(permission_name, object.id).each do |group|
          group = Group.find(group.id)
          group.permission.send("#{permission_name}=", group.permission.send(permission_name) - [object.id])
          group.save!
        end

        groups.each do |group_id|
          group = Group.find(group_id)
          group.permission.send("#{permission_name}=", (group.permission.send(permission_name) + [object.id]).uniq)
          group.save!
        end
      end

    end
  end
end
