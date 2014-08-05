class Inventory::Section < Inventory::Base
  belongs_to :category, class_name: "Inventory::Category", foreign_key: "inventory_category_id"
  has_many :fields, class_name: "Inventory::Field",
                    foreign_key: "inventory_section_id",
                    autosave: true

  validates :title, presence: true
  validates :required, inclusion: { in: [true, false] }

  before_validation :set_default_attributes

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :required
    expose :location
    expose :inventory_category_id
    expose :position
    expose :fields, using: Inventory::Field::Entity
  end

  private
    def set_default_attributes
      self.required = false if required.nil?
      true
    end
end
