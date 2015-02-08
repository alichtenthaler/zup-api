class Inventory::CreateFormForCategory
  attr_reader :category, :form_structure

  def initialize(category, form_structure)
    @category, @form_structure = category, form_structure
  end

  def create!
    create_or_update_sections
  end

  private
    def create_or_update_sections
      Inventory::Section.transaction do
        form_structure["sections"].each do |section|
          if section["id"].blank?
            found_section = category.sections.create!(params_for_section(section))
          else # section already exists
            # if it has the destroy attribute, we
            # should destroy id
            found_section = category.sections.find(section["id"])

            if section["destroy"]
              found_section.disable! and found_section = nil
            else
              found_section.update(
                title: section["title"],
                position: section["position"]
              )
            end
          end

          if found_section
            updates_group_permission_for_section(found_section, section['permissions'])
            create_or_update_fields_for_section(found_section, section)
          end
        end
      end
    end

    def create_or_update_fields_for_section(section, fields_data)
      return if section.nil?

      Inventory::Field.transaction do
        fields_data["fields"].each do |field|
          if field["id"].blank?
            found_field = section.fields.create(params_for_field(field))
          else # field already exists
            found_field = section.fields.find(field["id"])

            if field["destroy"]
              found_field.disable! and found_field = nil
            else
              found_field.update(params_for_field(field))
            end
          end

          if found_field
            updates_group_permission_for_field(found_field, field['permissions'])
          end
        end
      end
    end

    # TODO: Refactor these methods
    def updates_group_permission_for_field(field, permissions)
      return if field.nil?

      unless permissions.nil? || permissions.empty?
        groups_can_view = permissions['groups_can_view']
        groups_can_edit = permissions['groups_can_edit']

        if groups_can_view
          # Remove permission of groups
          Group.that_includes_permission(:inventory_fields_can_view, field.id).each do |group|
            group = Group.find(group.id)
            group.permission.atomic_remove(:inventory_fields_can_view, field.id)
          end

          groups_can_view.each do |group_id|
            group = Group.find(group_id)
            group.permission.atomic_append(:inventory_fields_can_view, field.id)
          end
        end

        if groups_can_edit
          # Remove permission of groups
          Group.that_includes_permission(:inventory_fields_can_edit, field.id).each do |group|
            group = Group.find(group.id)
            group.permission.atomic_remove(:inventory_fields_can_edit, field.id)
          end

          groups_can_edit.each do |group_id|
            group = Group.find(group_id)
            group.permission.atomic_append(:inventory_fields_can_edit, field.id)
          end
        end
      end
    end

    def updates_group_permission_for_section(section, permissions)
      return if section.nil?

      unless permissions.nil? || permissions.empty?
        groups_can_view = permissions['groups_can_view']
        groups_can_edit = permissions['groups_can_edit']

        if groups_can_view
          # Remove permission of groups
          Group.that_includes_permission(:inventory_sections_can_view, section.id).each do |group|
            group = Group.find(group.id)
            group.permission.atomic_remove(:inventory_sections_can_view, section.id)
          end

          groups_can_view.each do |group_id|
            group = Group.find(group_id)
            group.permission.atomic_append(:inventory_sections_can_view, section.id)
          end
        end

        if groups_can_edit
          # Remove permission of groups
          Group.that_includes_permission(:inventory_sections_can_edit, section.id).each do |group|
            group.permission.atomic_remove(:inventory_sections_can_edit, section.id)
          end

          groups_can_edit.each do |group_id|
            group = Group.find(group_id)
            group.permission.atomic_append(:inventory_sections_can_edit, section.id)
          end
        end
      end
    end

    def params_for_section(section)
      {
        title: section["title"],
        position: section["position"],
        required: section["required"]
      }
    end

    def params_for_field(field)
      title = field.delete("title")
      position = field.delete("position")
      kind = field.delete("kind")
      available_values = field.delete("available_values")
      maximum = field.delete("maximum")
      minimum = field.delete("minimum")
      required = field.delete("required")

      {
        title: title,
        position: position,
        kind: kind,
        available_values: available_values,
        options: field,
        maximum: maximum,
        minimum: minimum,
        required: required
      }
    end
end
