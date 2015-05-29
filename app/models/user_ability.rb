class UserAbility
  include CanCan::Ability

  attr_reader :user, :permissions

  def self.for_user(user)
    key = (user.try(:id) || '0').to_s + '-' + Group.cache_version.to_s
    @abilities ||= {}

    unless @abilities[key]
      clear_invalid_cache
      @abilities[key] = new(user)
    end

    @abilities[key]
  end

  def self.clear_invalid_cache
    current_version_key = '-' + Group.cache_version.to_s
    @abilities.keys.each do |k|
      if k[-current_version_key.size..-1] != current_version_key
        @abilities.delete(k)
      end
    end
  end

  # TODO: Make this work with the Guest group.
  def initialize(given_user = nil)
    @user = (given_user || User::Guest.new)
    @permissions = user.permissions

    if permissions.panel_access
      can :access, 'Panel'
    end

    if permissions.create_reports_from_panel
      can :create_from_panel, Reports::Item
    end

    if permissions.manage_config
      can :manage, FeatureFlag
    end

    if permissions.users_full_access
      can :manage, User
    else
      can :manage, User do |u|
        ((permissions.group_edit || []) & u.groups.pluck(:id)).any?
      end
    end

    if permissions.groups_full_access
      can :manage, Group
      can :manage, User
    end

    if permissions.inventories_full_access
      can :manage, Inventory::Category
      can :manage, Inventory::Field
      can :manage, Inventory::Section
      can :manage, Inventory::Item
    end

    if permissions.reports_full_access
      can :manage, Reports::Category
      can :manage, Reports::Item
    end

    if permissions.manage_flows
      can :manage, Flow
      can :manage, ResolutionState
      can :manage, Step
      can :manage, Field
      can :manage, Trigger
    end

    if permissions.inventories_formulas_full_access
      can :manage, Inventory::Formula
      can :manage, Inventory::FormulaCondition
    end

    # Users permissions
    # User can edit it's own info
    can :edit, User do |u|
      u.id == user.id
    end

    can :manage, User do |u|
      (u.group_ids & (permissions.users_edit || [])).any?
    end

    # Specific groups permissions
    can [:edit, :view], Group do |group|
      permissions.group_edit.include?(group.id)
    end

    can :view, Group do |group|
      permissions.group_read_only.include?(group.id)
    end

    # Reports category permissions
    can [:edit, :view], Reports::Category do |category|
      permissions.reports_categories_edit.include?(category.id)
    end

    can :view, Reports::Category do |category|
      permissions.reports_items_read_public.include?(category.id) ||
      permissions.reports_items_create.include?(category.id) ||
      permissions.reports_items_delete.include?(category.id)
    end

    # Inventory category permissions
    can [:view, :edit], Inventory::Category do |category|
      permissions.inventories_categories_edit.include?(category.id) ||
      permissions.inventories_items_edit.include?(category.id)
    end

    can :view, Inventory::Category do |category|
      permissions.inventories_items_read_only.include?(category.id) ||
      permissions.inventories_items_create.include?(category.id) ||
      permissions.inventories_items_delete.include?(category.id)
    end

    can :view_all_items, Inventory::Category do |category|
      permissions.inventories_items_edit.include?(category.id) ||
      permissions.inventories_categories_edit.include?(category.id) ||
      permissions.inventories_items_read_only.include?(category.id) ||
      permissions.inventories_items_delete.include?(category.id)
    end

    # Reports items permissions
    can [:view, :edit, :forward, :alter_status], Reports::Item do |report|
      permissions.reports_items_edit.include?(report.reports_category_id) ||
      permissions.reports_categories_edit.include?(report.reports_category_id)
    end

    can [:view, :create], Reports::Item do |report|
      permissions.reports_items_create.include?(report.reports_category_id) ||
      permissions.reports_categories_edit.include?(report.reports_category_id)
    end

    can [:view, :delete], Reports::Item do |report|
      permissions.reports_items_delete.include?(report.reports_category_id) ||
      permissions.reports_categories_edit.include?(report.reports_category_id)
    end

    can :view, Reports::Item do |report|
      permissions.reports_items_read_public.include?(report.reports_category_id) ||
        permissions.reports_categories_edit.include?(report.reports_category_id)
    end

    can :view_private, Reports::Item do |report|
      permissions.reports_items_read_private.include?(report.reports_category_id)
    end

    can :forward, Reports::Item do |report|
      permissions.reports_items_forward.include?(report.reports_category_id)
    end

    can :alter_status, Reports::Item do |report|
      permissions.reports_items_alter_status.include?(report.reports_category_id)
    end

    # Inventory items permissions
    can [:view, :edit], Inventory::Item do |inventory_item|
      permissions.inventories_items_edit.include?(inventory_item.inventory_category_id) ||
      permissions.inventories_categories_edit.include?(inventory_item.inventory_category_id)
    end

    can :view, Inventory::Item do |inventory_item|
      permissions.inventories_items_read_only.include?(inventory_item.inventory_category_id) ||
      permissions.inventories_categories_edit.include?(inventory_item.inventory_category_id)
    end

    can [:view, :create], Inventory::Item do |inventory_item|
      permissions.inventories_items_create.include?(inventory_item.inventory_category_id)
    end

    can [:view, :delete], Inventory::Item do |inventory_item|
      permissions.inventories_items_delete.include?(inventory_item.inventory_category_id) ||
      permissions.inventories_categories_edit.include?(inventory_item.inventory_category_id)
    end

    # Inventory sections permissions
    can [:view, :edit], Inventory::Section do |inventory_section|
      permissions.inventory_sections_can_edit.include?(inventory_section.id)
    end

    can :view, Inventory::Section do |inventory_section|
      permissions.inventory_sections_can_view.include?(inventory_section.id)
    end

    # Inventory fields permissions
    can [:view, :edit], Inventory::Field do |inventory_field|
      permissions.inventory_fields_can_edit.include?(inventory_field.id)
    end

    can :view, Inventory::Field do |inventory_field|
      permissions.inventory_fields_can_view.include?(inventory_field.id)
    end

    # ===============================
    # - Cases permissions
    # ===============================
    can :show, Step do |step|
      can_execute_step      = permissions.can_execute_step.include?(step.id)
      can_view_step         = permissions.can_view_step.include?(step.id)
      can_execute_all_steps = permissions.flow_can_execute_all_steps.include?(step.flow.id)
      can_view_all_steps    = permissions.flow_can_view_all_steps.include?(step.flow.id)
      can_execute_step || can_view_step || can_execute_all_steps || can_view_all_steps
    end

    can :show, Case do |_kase|
      # if user has any one these options should be understood that he can see Case
      can_execute_step      = permissions.can_execute_step.present?
      can_view_step         = permissions.can_view_step.present?
      can_execute_all_steps = permissions.flow_can_execute_all_steps.present?
      can_view_all_steps    = permissions.flow_can_view_all_steps.present?
      can_execute_step || can_view_step || can_execute_all_steps || can_view_all_steps
    end

    can :update, Case do |kase|
      kase.responsible_user_id == user.id || user.groups.pluck(:id).include?(kase.responsible_group_id)
    end

    can :delete, Case do |kase|
      flow_can_delete_all_cases = permissions.flow_can_delete_all_cases.include?(kase.initial_flow_id)
      flow_can_delete_own_cases = permissions.flow_can_delete_own_cases.include?(kase.initial_flow_id)
      flow_can_delete_all_cases || (flow_can_delete_own_cases && (kase.responsible_user_id == user.id || user.groups.pluck(:id).include?(kase.responsible_group_id)))
    end

    can :restore, Case do |kase|
      flow_can_delete_all_cases = permissions.flow_can_delete_all_cases.include?(kase.initial_flow_id)
      flow_can_delete_own_cases = permissions.flow_can_delete_own_cases.include?(kase.initial_flow_id)
      flow_can_delete_all_cases || (flow_can_delete_own_cases && (kase.responsible_user_id == user.id || user.groups.pluck(:id).include?(kase.responsible_group_id)))
    end

    can :create, CaseStep do |case_step|
      can_execute_step      = permissions.can_execute_step.include?(case_step.step.id)
      can_execute_all_steps = permissions.flow_can_execute_all_steps.include?(case_step.step.flow.id)
      can_execute_step || can_execute_all_steps
    end

    can :update, CaseStep do |case_step|
      can_execute_step      = permissions.can_execute_step.include?(case_step.step.id)
      can_execute_all_steps = permissions.flow_can_execute_all_steps.include?(case_step.step.flow.id)
      can_execute_step || can_execute_all_steps
    end

    can :show, CaseStep do |case_step|
      can_execute_step      = permissions.can_execute_step.include?(case_step.step.id)
      can_view_step         = permissions.can_view_step.include?(case_step.step.id)
      can_execute_all_steps = permissions.flow_can_execute_all_steps.include?(case_step.step.flow.id)
      can_view_all_steps    = permissions.flow_can_view_all_steps.include?(case_step.step.flow.id)
      can_execute_step || can_view_step || can_execute_all_steps || can_view_all_steps
    end
  end

  def inventory_categories_visible
    (permissions.inventories_categories_edit + \
     permissions.inventories_items_read_only + \
     permissions.inventories_items_edit + \
     permissions.inventories_items_create + \
     permissions.inventories_items_delete).uniq
  end

  def inventory_sections_visible
    (permissions.inventory_sections_can_view + permissions.inventory_sections_can_edit).uniq
  end

  def reports_categories_visible
    (permissions.reports_items_read_public + \
     permissions.reports_items_read_private + \
     permissions.reports_items_edit + \
     permissions.reports_categories_edit + \
     permissions.reports_items_create + \
     permissions.reports_items_delete).uniq
  end

  def reports_categories_visible_for_items
    (permissions.reports_items_read_public + \
     permissions.reports_items_read_private + \
     permissions.reports_items_edit + \
     permissions.reports_categories_edit + \
     permissions.reports_items_delete).uniq
  end

  def inventory_fields_visible
    (permissions.inventory_fields_can_view + permissions.inventory_fields_can_edit).uniq
  end

  def groups_visible
    (permissions.group_read_only + permissions.group_edit + permissions.users_edit).uniq
  end
end
