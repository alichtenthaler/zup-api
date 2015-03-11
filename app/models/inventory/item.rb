class Inventory::Item < Inventory::Base
  include LikeSearchable

  set_rgeo_factory_for_column(:position, RGeo::Geographic.simple_mercator_factory)

  belongs_to :user
  belongs_to :category, class_name: "Inventory::Category", foreign_key: "inventory_category_id"
  belongs_to :status, class_name: "Inventory::Status", foreign_key: "inventory_status_id"
  belongs_to :locker, class_name: "User"

  has_many :data, class_name: "Inventory::ItemData",
                  foreign_key: "inventory_item_id",
                  autosave: true,
                  include: [:field],
                  dependent: :destroy

  has_many :fields, class_name: "Inventory:Field",
                    through: :category

  has_many :field_options, class_name: "Inventory::FieldOption",
                     through: :fields

  has_many :selected_options, class_name: "Inventory::FieldOption",
                     through: :data,
                     source: :option
  has_many :histories, class_name: "Inventory::ItemHistory",
                       foreign_key: "inventory_item_id",
                       dependent: :destroy
  has_many :images, class_name: "Inventory::ItemDataImage",
                    through: :data

  before_validation :update_position_from_data
  before_validation :generate_title

  validates :category, presence: true
  validates :user, presence: true
  validates :title, presence: true
  validates :status, presence: true, if: :must_have_status?

  scope :locked, -> { where(locked: true) }

  def location
    @location ||= Hash[
      self.data.joins { field }
               .where { field.title >> ['latitude', 'longitude', 'address'] }
               .map do |item_data|
                 [item_data.field.title.to_sym, item_data.content]
               end
    ]

    @location[:latitude] = @location[:latitude].to_f
    @location[:longitude] = @location[:longitude].to_f

    @location
  end

  class Entity < Grape::Entity
    expose :id
    expose :title do |obj, _|
      "#{obj.title} ##{obj.sequence}"
    end
    expose :address
    expose :inventory_status_id
    expose :locked
    expose :locker_id
    expose :locked_at

    # TODO: Find out why this is happening
    expose :position do |obj, _|
      if obj.respond_to?(:position) && !obj.position.nil?
        { latitude: obj.position.y, longitude: obj.position.x }
      end
    end

    with_options(if: { display_type: 'full'}) do
      expose :user, using: User::Entity
      expose :category, using: Inventory::Category::Entity
    end

    expose :inventory_category_id, unless: { display_type: 'full' }
    expose :data, unless: { display_type: 'basic' }
    expose :created_at
    expose :updated_at

    private

    def data
      user = options[:user]
      objects = object.data
      permissions = UserAbility.new(user)

      unless permissions.can?(:manage, Inventory::Item)
        ids = permissions.inventory_fields_visible
        objects = objects.where(inventory_field_id: ids)
      end

      Inventory::ItemData::Entity.represent(objects, options)
    end

  end

  # Data with Inventory::ItemDataRepresenter
  def represented_data(user = nil)
    @represented_data ||= Inventory::ItemDataRepresenter.factory(self, user)
  end

  private
    def must_have_status?
      category && category.require_item_status?
    end

    # TODO: Singularize portuguese words
    def generate_title
      if category && (new_record?)
        self.title = category.title
        self.sequence = category.items.count + 1
      end
    end

    # TODO: This should be in the representer class
    def update_position_from_data
      latitude, longitude, dynamic_address = nil

      # TODO: Find a way to select the data with
      # location fields, automatically.
      self.data.each do |data|
        next unless data.field.present?
        next unless data.field.location

        if data.field.title == "latitude"
          latitude = data.content
        elsif data.field.title == "longitude"
          longitude = data.content
        elsif data.field.title == "address"
          dynamic_address = data.content
        end
      end

      if latitude && longitude
        self.position = ::Reports::Item.rgeo_factory.point(longitude, latitude)
      end

      if !self.address_changed? && dynamic_address
        self.address = dynamic_address
      end
    end
end
