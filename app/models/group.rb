class Group < ActiveRecord::Base
  include StoreAccessorTypes

  store_accessor  :permissions,                   :manage_flows,
                  :manage_users,                  :manage_inventory_categories,
                  :manage_inventory_items,        :manage_groups,
                  :manage_reports_categories,     :manage_reports,
                  :manage_inventory_formulas,
                  :view_categories,               :view_sections,
                  :groups_can_edit,               :groups_can_view,
                  :reports_categories_can_edit,   :reports_categories_can_view,
                  :inventory_categories_can_edit, :inventory_categories_can_view,
                  :inventory_sections_can_view,   :inventory_sections_can_edit,
                  :flow_can_view_all_steps,       :flow_can_execute_all_steps,
                  :flow_can_delete_own_cases,     :flow_can_delete_all_cases,
                  :flow_can_execute_all_steps,    :can_view_step,
                  :can_execute_step,
                  :inventory_fields_can_edit,     :inventory_fields_can_view

  # Hstore getters
  treat_as_array  :groups_can_edit,               :groups_can_view,
                  :reports_categories_can_edit,   :reports_categories_can_view,
                  :inventory_categories_can_edit, :inventory_categories_can_view,
                  :inventory_sections_can_view,   :inventory_sections_can_edit,
                  :flow_can_view_all_steps,       :flow_can_execute_all_steps,
                  :flow_can_delete_own_cases,     :can_view_step,
                  :can_execute_step,
                  :inventory_fields_can_edit,     :inventory_fields_can_view

  treat_as_boolean  :manage_users,   :manage_inventory_categories,
                    :manage_flows,   :manage_inventory_items,
                    :manage_groups,  :manage_reports_categories,
                    :manage_reports, :manage_inventory_formulas,
                    :view_categories, :view_sections

  has_and_belongs_to_many :users

  validates :name, presence: true
  validates :permissions, presence: true
  validates :guest, inclusion: { in: [true, false] }

  before_validation :set_default_attributes

  scope :guest, -> { where(guest: true) }
  default_scope -> { order("id ASC") }

  def self.with_permission(permission_name)
    self.where("permissions -> ? = 'true'", permission_name).first
  end

  def self.included_in_permission?(groups, permission_name, id)
    permission_array = groups.inject([]) do |permissions, group|
      permissions += group.send(permission_name.to_s)
    end

    permission_array.include?(id)
  end

  def typed_permissions
    if permissions.any?
      typed_permissions = {}

      permissions.each do |name, _|
        if self.respond_to?(name)
          typed_permissions[name] = self.send(name)
        end
      end

      return typed_permissions
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
      self.permissions ||= {
        view_categories: true,
        view_sections: true
      }
    end
end
