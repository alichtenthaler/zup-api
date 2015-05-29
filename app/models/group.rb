class Group < ActiveRecord::Base
  include MemoryCache
  include LikeSearchable

  has_and_belongs_to_many :users, uniq: true
  has_one :permission, class_name: 'GroupPermission', autosave: true

  validates :name, presence: true, uniqueness: true
  validates :guest, inclusion: { in: [true, false] }

  before_validation :set_default_attributes

  scope :guest, -> { where(guest: true) }
  default_scope -> { order('groups.id ASC') }

  def self.with_permission(permission_name)
    joins(:permission)
      .where(group_permissions: { permission_name => true }).first
  end

  def self.that_includes_permission(permission_name, id)
    includes(:permission).select do |group|
      group.permission.send(permission_name).include?(id)
    end
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
    build_permission unless permission.present?
  end

  enable_memory_cache ignore_assoc_table: [:group_users, :users]
end
