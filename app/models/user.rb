class User < ActiveRecord::Base
  include PasswordAuthenticable
  include LikeSearchable
  include Unsubscribeable

  attr_accessor :from_webhook, :ignore_password_requirement

  has_many :access_keys
  has_many :reports, class_name: 'Reports::Item', foreign_key: 'user_id'
  has_and_belongs_to_many :groups, uniq: true
  has_many :groups_permissions, through: :groups,
                                class_name: 'GroupPermission',
                                source: :permission
  has_many :feedbacks, class_name: 'Reports::Feedback'
  has_many :flows, class_name: 'Flow', foreign_key: :created_by_id
  has_many :cases, class_name: 'Case', foreign_key: :created_by_id
  has_many :cases_log_entries

  EMAIL_REGEXP = /\A(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|
                    ([A-Za-z0-9]+\++))*[A-Z<200c><200b>a-z0-9]+@((\w+\-+)|
                    (\w+\.))*\w{1,63}\.[a-zA-Z]{2,6}\z/x

  validates :email, presence: true,
                    uniqueness: { scope: [:disabled] },
                    format: { with: EMAIL_REGEXP }
  validates :name, presence: true, length: { in: 4..64 }

  with_options unless: :from_webhook do |u|
    u.validates :encrypted_password, presence: true
    u.validates :phone, presence: true
    u.validates :document, presence: true
    u.validates :address, presence: true
    u.validates :postal_code, presence: true
    u.validates :district, presence: true
  end

  before_create :generate_access_key!

  scope :enabled, -> { where(disabled: false) }

  def self.authorize(token)
    if ak = AccessKey.active.find_by(key: token)
      return ak.user
    else
      nil
    end
  end

  def last_access_key
    access_keys.active.last.key
  end

  def generate_access_key!
    if self.new_record?
      access_keys.build
    else
      access_keys.create
    end
  end

  def to_json(options = {})
    options[:except] ||= [:encrypted_password, :salt]
    super(options)
  end

  def guest?
    false
  end

  def disable!
    update!(disabled: true)
  end

  def enable!
    update!(disabled: false)
  end

  def enabled?
    !disabled?
  end

  def group_ids
    if ENV['DISABLE_MEMORY_CACHE'] == 'true'
      groups.pluck(:id)
    else
      @group_ids ||= groups.pluck(:id)
    end
  end

  # Compile all user permissions from group
  def permissions
    struct = OpenStruct.new

    Group.cached_find(group_ids).each do |group|
      GroupPermission.permissions_columns.each do |c|
        value = group.permission.send(c)

        if value.is_a?(Array)
          struct[c] ||= []
          struct[c] += value
          struct[c] = struct[c].uniq
        else
          struct[c] = value unless struct[c] === true
        end
      end
    end

    struct
  end

  def reload_permissions
    @permissions = nil
  end

  def groups_names
    if groups.any?
      groups.map(&:name)
    else
      []
    end
  end

  def push_notification_available?
    device_type && device_token
  end

  class Entity < Grape::Entity
    expose :id
    expose :name
    expose :disabled
    expose :groups, with: Group::Entity, unless: lambda { |_, opts| opts[:collection] == true && !opts[:show_groups] }
    expose :permissions, unless: { collection: true }
    expose :groups_names, unless: { collection: true }

    with_options(if: { display_type: 'full' }) do
      expose :email
      expose :phone
      expose :document
      expose :address
      expose :address_additional
      expose :postal_code
      expose :district
      expose :city
      expose :device_token
      expose :device_type
      expose :created_at
      expose :facebook_user_id
      expose :twitter_user_id
      expose :google_plus_user_id
    end

    def permissions
      object.permissions.to_h
    end
  end

  class ListingEntity < Grape::Entity
    expose :id
    expose :name
  end

  class Guest < User
    def id
      -1
    end

    def groups
      Group.guest
    end

    def guest?
      true
    end

    def save
      false
    end

    def cache_key
      'user/0'
    end

    def save!
      false
    end
  end
end
