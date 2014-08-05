class Inventory::Item < Inventory::Base
  include LikeSearchable

  set_rgeo_factory_for_column(:position, RGeo::Geographic.simple_mercator_factory)

  belongs_to :user
  belongs_to :category, class_name: "Inventory::Category", foreign_key: "inventory_category_id"
  belongs_to :status, class_name: "Inventory::Status", foreign_key: "inventory_status_id"

  has_many :data, class_name: "Inventory::ItemData",
                  foreign_key: "inventory_item_id",
                  autosave: true,
                  include: [:field]

  before_validation :update_position_from_data
  before_validation :generate_title

  validates :category, presence: true
  validates :user, presence: true
  validates :title, presence: true
  validates :status, presence: true, if: :must_have_status?

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
    expose :title
    expose :address
    expose :inventory_status_id

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
    expose :data, using: Inventory::ItemData::Entity
    expose :created_at
  end

  # Data with Inventory::ItemDataRepresenter
  def represented_data
    @represented_data ||= Inventory::ItemDataRepresenter.factory(self)
  end

  private
    def must_have_status?
      category && category.require_item_status?
    end

    # TODO: Singularize portuguese words
    def generate_title
      if category && (new_record?)
        self.title = "#{category.title} ##{category.items.count + 1}"
      end
    end

    def update_position_from_data
      latitude, longitude, dynamic_address = nil

      # TODO: Find a way to select the data with
      # location fields, automatically.
      self.data.each do |data|
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
