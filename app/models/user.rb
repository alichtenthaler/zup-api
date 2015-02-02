class User < ActiveRecord::Base
  include PasswordAuthenticable
  include LikeSearchable

  has_many :access_keys
  has_many :reports, class_name: "Reports::Item", foreign_key: "user_id"
  has_and_belongs_to_many :groups
  has_many :feedbacks, class_name: 'Reports::Feedback'
  has_many :flows, class_name: 'Flow', foreign_key: :created_by_id
  has_many :cases, class_name: 'Case', foreign_key: :created_by_id
  has_many :cases_log_entries

  validates :email, presence: true, uniqueness: true
  validates :encrypted_password, presence: true
  validates :phone, presence: true
  validates :document, presence: true
  validates :address, presence: true
  validates :postal_code, presence: true
  validates :name, presence: true, length: { in: 4..64 }
  validates :district, presence: true

  before_create :generate_access_key!

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

  def to_json(options={})
    options[:except] ||= [:encrypted_password, :salt]
    super(options)
  end

  def entity
    Entity.new(self)
  end

  def guest?
    false
  end

  # Compile all user permissions from group
  def permissions
    perms = {}

    self.groups.each do |group|
      GroupPermission.permissions_columns.each do |c|
        key = c.name
        value = group.permission.send(key)

        if value.is_a?(Array)
          perms[key] ||= []
          perms[key] += value
          perms[key] = perms[key].uniq
        else
          perms[key] = value unless perms[key] === true
        end
      end
    end

    perms
  end

  def groups_names
    if groups.any?
      groups.map(&:name)
    else
      []
    end
  end

  class Entity < Grape::Entity
    expose :id
    expose :name
    expose :groups, with: Group::Entity, unless: { collection: true }
    expose :permissions
    expose :groups_names

    with_options(if: { display_type: 'full'}) do
      expose :email
      expose :phone
      expose :document
      expose :address
      expose :address_additional
      expose :postal_code
      expose :district
      expose :device_token
      expose :device_type
      expose :created_at
      expose :facebook_user_id
      expose :twitter_user_id
      expose :google_plus_user_id
    end
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

    def save!
      false
    end
  end
end
