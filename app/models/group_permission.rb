class GroupPermission < ActiveRecord::Base
  include AtomicArrays

  class Boolean
  end

  TYPES_CLASSES = {
    flow: Flow,
    user: User,
    group: Group,
    inventory: Inventory::Category,
    report: Reports::Category
  }

  # Types of permissions
  TYPES = {
    flow: {
      "manage_flows" => Boolean,
      "flow_can_view_all_steps" => Array,
      "flow_can_execute_all_steps" => Array,
      # "can_view_step" => Array,
      # "can_execute_step" => Array,
      "flow_can_delete_all_cases" => Array,
      "flow_can_delete_own_cases" => Array
    },

    user: {
      "manage_users" => Boolean,
    },

    group: {
      "groups_can_edit" => Array,
      "groups_can_view" => Array,
      "manage_groups" => Boolean
    },

    other: {
      "manage_config" => Boolean,
      "panel_access" => Boolean,
      "view_categories" => Boolean,
      "view_sections" => Boolean
    },

    inventory: {
      "inventory_categories_can_edit" => Array,
      "inventory_categories_can_view" => Array,
      # "inventory_sections_can_view" => Array,
      # "inventory_sections_can_edit" => Array,
      # "inventory_fields_can_edit" => Array,
      # "inventory_fields_can_view" => Array,
      "delete_inventory_items" => Boolean,
      "edit_inventory_items" => Boolean,
      "manage_inventory_formulas" => Boolean,
      "manage_inventory_categories" => Boolean,
      "manage_inventory_items" => Boolean
    },

    report: {
      "delete_reports" => Boolean,
      "edit_reports" => Boolean,
      "reports_categories_can_edit" => Array,
      "reports_categories_can_view" => Array,
      "create_reports_from_panel" => Boolean,
      "manage_reports_categories" => Boolean,
      "manage_reports" => Boolean
    }
  }

  belongs_to :group

  def self.permissions_columns
    self.column_names - %w(id group_id)
  end
end
