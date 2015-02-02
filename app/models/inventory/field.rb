require 'string'

class Inventory::Field < Inventory::Base
  AVAILABLE_KINDS = {
   "text" => String,
   "textarea" => String,
   "integer" => Fixnum,
   "decimal" => Float,
   "meters" => Float,
   "centimeters" => Float,
   "kilometers" => Float,
   "years" => Fixnum,
   "months" => Fixnum,
   "days" => Fixnum,
   "hours" => Fixnum,
   "seconds" => Fixnum,
   "angle" => Fixnum,
   "date" => DateTime,
   "time" => Time,
   "cpf" => String,
   "cnpj" => String,
   "url" => String,
   "email" => String,
   "images" => Array,
   "attachments" => Array,
   "checkbox" => Array,
   "radio" => String,
   "select" => String
  }

  include StoreAccessorTypes
  store_accessor :options, :label, :location

  treat_as_boolean :location

  belongs_to :section, class_name: "Inventory::Section", foreign_key: "inventory_section_id"

  validates :title, presence: true, uniqueness: { scope: :inventory_section_id }
  validates :kind,  presence: true, inclusion: { in: AVAILABLE_KINDS.keys }
  validates :position, presence: true, numericality: true
  validates :required, inclusion: { in: [true, false] }

  before_validation :set_default_attributes

  scope :required, -> { where(required: true) }
  scope :location, -> { where("options -> 'location' = 'true'") }
  scope :disabled, -> { where(disabled: true) }
  scope :enabled, -> { where(disabled: false) }

  def content_type
    AVAILABLE_KINDS[self.kind]
  end

  # Group permissions
  def permissions
    {
      groups_can_view: groups_can_view,
      groups_can_edit: groups_can_edit
    }
  end

  def groups_can_view
    Group.that_includes_permission(:inventory_fields_can_view, self.id).map(&:id)
  end

  def groups_can_edit
    Group.that_includes_permission(:inventory_fields_can_edit, self.id).map(&:id)
  end

  def disable!
    self.update!(disabled: true)
  end

  class Entity < Grape::Entity
    expose :id
    expose :disabled
    expose :title
    expose :kind
    expose :size
    expose :inventory_section_id
    expose :available_values
    expose :permissions
    expose :position
    expose :label
    expose :maximum
    expose :minimum
    expose :required
    expose :location
    expose :created_at
    expose :updated_at
  end

  private
    def set_default_attributes
      self.required = false if required.nil?
      self.title = generate_title if title.nil? && label.present?
    end

    def generate_title
      generated_title = label.unaccented.downcase
      generated_title = generated_title.gsub(/\W/, '_')
      generated_title = "field_#{generated_title}"

      self.title = generated_title
    end
end
