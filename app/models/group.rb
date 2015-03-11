class Group < ActiveRecord::Base
  include StoreAccessorTypes

  store_accessor  :permissions,                   :manage_flows,
                  :manage_users,                  :manage_inventory_categories,
                  :manage_inventory_items,        :manage_groups,
                  :manage_reports_categories,     :manage_reports,
                  :manage_inventory_formulas,     :manage_config,
                  :delete_inventory_items,        :delete_reports,
                  :edit_inventory_items,          :edit_reports,
                  :view_categories,               :view_sections,
                  :groups_can_edit,               :groups_can_view,
                  :reports_categories_can_edit,   :reports_categories_can_view,
                  :inventory_categories_can_edit, :inventory_categories_can_view,
                  :inventory_sections_can_view,   :inventory_sections_can_edit,
                  :inventory_fields_can_edit,     :inventory_fields_can_view,
                  :flow_can_view_all_steps,       :flow_can_execute_all_steps,
                  :flow_can_delete_own_cases,     :flow_can_delete_all_cases,
                  :can_view_step,                 :can_execute_step,
                  :panel_access,                  :edit_reports,
                  :delete_reports

  # Hstore getters
  treat_as_array  :groups_can_edit,               :groups_can_view,
                  :reports_categories_can_edit,   :reports_categories_can_view,
                  :inventory_categories_can_edit, :inventory_categories_can_view,
                  :inventory_sections_can_view,   :inventory_sections_can_edit,
                  :flow_can_view_all_steps,       :flow_can_execute_all_steps,
                  :flow_can_delete_all_cases,     :flow_can_delete_own_cases,
                  :can_view_step,                 :can_execute_step,
                  :inventory_fields_can_edit,     :inventory_fields_can_view

  treat_as_boolean  :manage_users,           :manage_inventory_categories,
                    :manage_flows,           :manage_inventory_items,
                    :manage_groups,          :manage_reports_categories,
                    :manage_reports,         :manage_inventory_formulas,
                    :manage_config,          :edit_inventory_items,
                    :delete_inventory_items, :edit_reports,
                    :delete_reports,         :view_categories,
                    :view_sections,          :panel_access

  has_and_belongs_to_many :users
  has_one :permission, class_name: 'GroupPermission', autosave: true

  validates :name, presence: true
  validates :guest, inclusion: { in: [true, false] }

  before_validation :set_default_attributes

  scope :guest, -> { where(guest: true) }
  default_scope -> { order("id ASC") }

  def self.with_permission(permission_name)
    self.joins(:permission)
        .where(group_permissions: { permission_name => true }).first
  end

  def self.that_includes_permission(permission_name, id)
    self.joins(:permission)
        .where("? = ANY (group_permissions.#{permission_name})", id)
  end

  def self.ids_for_permission(groups, permission_name)
    groups.inject([]) do |permissions, group|
      permissions += group.permission.send(permission_name)
    end
  end

  def self.included_in_permission?(groups, permission_name, id)
    permission_array = ids_for_permission(groups, permission_name)
    permission_array.include?(id)
  end

  def typed_permissions
    if permission.present?
      typed_permissions = {}

      GroupPermission.permissions_columns.each do |c|
        typed_permissions[c] = permission.send(c)
      end

      return typed_permissions.with_indifferent_access
    end

    {}
  end

  class Entity < Grape::Entity
    expose :id
    expose :name
    expose :typed_permissions, as: :permissions
    expose :users, using: User::Entity,
                   unless: { collection: true }
  end

  private
    def set_default_attributes
      self.guest = false if guest.nil?
      self.build_permission(
        view_categories: true,
        view_sections: true
      ) unless permission.present?
    end
end
