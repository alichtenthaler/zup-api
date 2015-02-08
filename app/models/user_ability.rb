class UserAbility
  include CanCan::Ability

  attr_accessor :user

  # TODO: Make this work with the Guest group.
  def initialize(given_user = nil)
    @user = (given_user or User::Guest.new)
    user_groups = user.groups

    if user.guest?
      can :view, Inventory::Category
      can :view, Reports::Category
    else
      # TODO: Essa permissão precisava ser dada a um grupo "Público" no qual
      # todos os usuários cadastrados farão parte por padrão
      can :create, Reports::Item

      if user_groups.with_permission(:panel_access)
        can :access, "Panel"
      end

      if user_groups.with_permission(:create_reports_from_panel)
        can :create_from_panel, Reports::Item
      end

      if user_groups.with_permission(:manage_users)
        can :manage, User
      end

      if user_groups.with_permission(:manage_groups)
        can :manage, Group
      end

      can :edit, User do |u|
        u.id == user.id
      end

      if user_groups.with_permission(:manage_inventory_categories)
        can :manage, Inventory::Category
      end

      if user_groups.with_permission(:manage_inventory_items)
        can :manage, Inventory::Item
      end

      if user_groups.with_permission(:manage_reports_categories)
        can :manage, Reports::Category
      end

      if user_groups.with_permission(:manage_reports)
        can :manage, Reports::Item
      end

      if user_groups.with_permission(:manage_config)
        can :manage, FeatureFlag
      end

      if user_groups.with_permission(:manage_flows)
        can :manage, Flow
        can :manage, ResolutionState
        can :manage, Step
        can :manage, Field
        can :manage, Trigger
      end

      if user_groups.with_permission(:edit_inventory_items)
        can :edit, Inventory::Item
        can :view, Inventory::Item
      end

      if user_groups.with_permission(:delete_inventory_items)
        can :destroy, Inventory::Item
        can :view, Inventory::Item
      end

      if user_groups.with_permission(:edit_reports)
        can :edit, Reports::Item
        can :view, Reports::Item
      end

      if user_groups.with_permission(:delete_reports)
        can :destroy, Reports::Item
        can :view, Reports::Item
      end

      can :show, Step do |step|
        can_execute_step      = Group.included_in_permission?(user_groups, :can_execute_step, step.id)
        can_view_step         = Group.included_in_permission?(user_groups, :can_view_step, step.id)
        can_execute_all_steps = Group.included_in_permission?(user_groups, :flow_can_execute_all_steps, step.flow.id)
        can_view_all_steps    = Group.included_in_permission?(user_groups, :flow_can_view_all_steps, step.flow.id)
        can_execute_step or can_view_step or can_execute_all_steps or can_view_all_steps
      end

      can :show, Case do |kase|
        # if user has any one these options should be understood that he can see Case
        can_see = false
        user_groups.each do |group|
          permission = group.permission
          next if permission.blank?
          can_execute_step      = permission.can_execute_step.present?
          can_view_step         = permission.can_view_step.present?
          can_execute_all_steps = permission.flow_can_execute_all_steps.present?
          can_view_all_steps    = permission.flow_can_view_all_steps.present?
          can_see = can_execute_step || can_view_step || can_execute_all_steps || can_view_all_steps
          break if can_see
        end
        can_see
      end

      can :update, Case do |kase|
        kase.responsible_user_id == user.id or user_groups.map(&:id).include? kase.responsible_group_id
      end

      if user_groups.with_permission(:flow_can_delete_all_cases)
        can :delete, Case
        can :restore, Case
      end

      if user_groups.with_permission(:flow_can_delete_own_cases)
        can :delete, Case do |kase|
          kase.responsible_user_id == user.id or user_groups.map(&:id).include? kase.responsible_group_id
        end

        can :restore, Case do |kase|
          kase.responsible_user_id == user.id or user_groups.map(&:id).include? kase.responsible_group_id
        end
      end

      can :create, CaseStep do |case_step|
        can_execute_step      = Group.included_in_permission?(user_groups, :can_execute_step, case_step.step.id)
        can_execute_all_steps = Group.included_in_permission?(user_groups, :flow_can_execute_all_steps, case_step.step.flow.id)
        can_execute_step or can_execute_all_steps
      end

      can :update, CaseStep do |case_step|
        can_execute_step      = Group.included_in_permission?(user_groups, :can_execute_step, case_step.step.id)
        can_execute_all_steps = Group.included_in_permission?(user_groups, :flow_can_execute_all_steps, case_step.step.flow.id)
        can_execute_step or can_execute_all_steps
      end

      can :show, CaseStep do |case_step|
        can_execute_step      = Group.included_in_permission?(user_groups, :can_execute_step, case_step.step.id)
        can_view_step         = Group.included_in_permission?(user_groups, :can_view_step, case_step.step.id)
        can_execute_all_steps = Group.included_in_permission?(user_groups, :flow_can_execute_all_steps, case_step.step.flow.id)
        can_view_all_steps    = Group.included_in_permission?(user_groups, :flow_can_view_all_steps, case_step.step.flow.id)
        can_execute_step or can_view_step or can_execute_all_steps or can_view_all_steps
      end

      if user_groups.with_permission(:manage_inventory_formulas)
        can :manage, Inventory::Formula
        can :manage, Inventory::FormulaCondition
      end

      # Simple view permissions
      if user_groups.with_permission(:view_categories)
        can :view, Inventory::Category
        can :view, Reports::Category
      end

      if user_groups.with_permission(:view_sections)
        can :view, Inventory::Section
        can :view, Inventory::Field
      end

      # Specific groups permissions
      can :edit, Group do |group|
        Group.included_in_permission?(user_groups, :groups_can_edit, group.id)
      end

      can :view, Group do |group|
        Group.included_in_permission?(user_groups, :groups_can_view, group.id) || \
          Group.included_in_permission?(user_groups, :groups_can_edit, group.id)
      end

      # Reports category permissions
      can :edit, Reports::Category do |category|
        Group.included_in_permission?(user_groups, :reports_categories_can_edit, category.id)
      end

      can :view, Reports::Category do |category|
        Group.included_in_permission?(user_groups, :reports_categories_can_edit, category.id) || \
          Group.included_in_permission?(user_groups, :reports_categories_can_view, category.id)
      end

      # Inventory category permissions
      can :edit, Inventory::Category do |category|
        Group.included_in_permission?(user_groups, :inventory_categories_can_edit, category.id)
      end

      can :view, Inventory::Category do |category|
        Group.included_in_permission?(user_groups, :inventory_categories_can_edit, category.id) || \
          Group.included_in_permission?(user_groups, :inventory_categories_can_view, category.id)
      end

      # Reports items permissions
      can :edit, Reports::Item do |report|
        Group.included_in_permission?(user_groups, :reports_categories_can_edit, report.reports_category_id)
      end

      can :view, Reports::Item do |report|
        Group.included_in_permission?(user_groups, :reports_categories_can_edit, report.reports_category_id) || \
          Group.included_in_permission?(user_groups, :reports_categories_can_view, report.reports_category_id)
      end

      # Inventory items permissions
      can :edit, Inventory::Item do |inventory_item|
        Group.included_in_permission?(user_groups, :inventory_categories_can_edit, inventory_item.inventory_category_id)
      end

      can :view, Inventory::Item do |inventory_item|
        Group.included_in_permission?(user_groups, :inventory_categories_can_view, inventory_item.inventory_category_id) || \
          Group.included_in_permission?(user_groups, :inventory_categories_can_view, inventory_item.inventory_category_id)
      end

      # Inventory sections permissions
      can :edit, Inventory::Section do |inventory_section|
        Group.included_in_permission?(user_groups, :inventory_sections_can_edit, inventory_section.id)
      end

      can :view, Inventory::Section do |inventory_section|
        Group.included_in_permission?(user_groups, :inventory_sections_can_view, inventory_section.id) || \
          Group.included_in_permission?(user_groups, :inventory_sections_can_view, inventory_section.id)
      end

      # Inventory fields permissions
      can :edit, Inventory::Field do |inventory_field|
        Group.included_in_permission?(user_groups, :inventory_fields_can_edit, inventory_field.id)
      end

      can :view, Inventory::Field do |inventory_field|
        Group.included_in_permission?(user_groups, :inventory_fields_can_edit, inventory_field.id) || \
          Group.included_in_permission?(user_groups, :inventory_fields_can_view, inventory_field.id)
      end
    end
  end

  def inventory_categories_visible
    (Group.ids_for_permission(user.groups, :inventory_categories_can_view) + Group.ids_for_permission(user.groups, :inventory_categories_can_edit)).uniq
  end

  def inventory_sections_visible
    (Group.ids_for_permission(user.groups, :inventory_sections_can_view) + Group.ids_for_permission(user.groups, :inventory_sections_can_edit)).uniq
  end

  def reports_categories_visible
    (Group.ids_for_permission(user.groups, :reports_categories_can_view) + Group.ids_for_permission(user.groups, :reports_categories_can_edit)).uniq
  end

  def inventory_fields_visible
    (Group.ids_for_permission(user.groups, :inventory_fields_can_view) + Group.ids_for_permission(user.groups, :inventory_fields_can_edit)).uniq
  end
end
