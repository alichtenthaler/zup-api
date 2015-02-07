class Inventory::Section < Inventory::Base
  belongs_to :category, class_name: "Inventory::Category", foreign_key: "inventory_category_id"
  has_many :fields, class_name: "Inventory::Field",
                    foreign_key: "inventory_section_id",
                    autosave: true,
                    dependent: :destroy

  validates :title, presence: true
  validates :required, inclusion: { in: [true, false] }

  before_validation :set_default_attributes

  def disable!
    update!(disabled: true)

    # Disable all children fields
    fields.each do |field|
      field.disable! unless field.disabled?
    end
  end

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :disabled
    expose :required
    expose :location
    expose :inventory_category_id
    expose :position
    expose :fields

    def fields
      if options[:user]
        user_permissions = UserAbility.new(options[:user])

        if user_permissions.can?(:manage, object.category)
          fields = object.fields
        else
          fields = object.fields.enabled.where(id: user_permissions.inventory_fields_visible)
        end

        Inventory::Field::Entity.represent(fields)
      end
    end
  end

  private
    def set_default_attributes
      self.required = false if required.nil?
      true
    end
end
