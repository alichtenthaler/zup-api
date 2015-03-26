require 'string'

class Inventory::Field < Inventory::Base
  AVAILABLE_KINDS = {
   'text' => String,
   'textarea' => String,
   'integer' => Fixnum,
   'decimal' => Float,
   'meters' => Float,
   'centimeters' => Float,
   'kilometers' => Float,
   'years' => Fixnum,
   'months' => Fixnum,
   'days' => Fixnum,
   'hours' => Fixnum,
   'seconds' => Fixnum,
   'angle' => Fixnum,
   'date' => DateTime,
   'time' => Time,
   'cpf' => String,
   'cnpj' => String,
   'url' => String,
   'email' => String,
   'images' => Array,
   'attachments' => Array,
   'checkbox' => Array,
   'radio' => String,
   'select' => String
  }

  include StoreAccessorTypes
  store_accessor :options, :label, :location

  treat_as_boolean :location

  belongs_to :section, class_name: 'Inventory::Section',
                       foreign_key: 'inventory_section_id'
  has_many :field_options, class_name: 'Inventory::FieldOption',
                           foreign_key: 'inventory_field_id',
                           autosave: true

  validates :title, presence: true, uniqueness: { scope: [:inventory_section_id, :disabled] }
  validates :kind,  presence: true, inclusion: { in: AVAILABLE_KINDS.keys }
  validates :position, presence: true, numericality: true
  validates :required, inclusion: { in: [true, false] }

  before_validation :set_default_attributes

  scope :required, -> { where(required: true) }
  scope :location, -> { where("options -> 'location' = 'true'") }
  scope :disabled, -> { where(disabled: true) }
  scope :enabled, -> { where(inventory_fields: { disabled: false }) }

  def content_type
    AVAILABLE_KINDS[kind]
  end

  def field_options_values=(values)
    return [] if values.blank?

    values.each do |value|
      if value.is_a?(String)
        field_options.build(value: value)
      end
    end
  end

  # Group permissions
  def permissions
    {
      groups_can_view: groups_can_view,
      groups_can_edit: groups_can_edit
    }
  end

  def groups_can_view
    Group.that_includes_permission(:inventory_fields_can_view, id).map(&:id)
  end

  def groups_can_edit
    Group.that_includes_permission(:inventory_fields_can_edit, id).map(&:id)
  end

  def disable!
    update!(disabled: true)
    field_options.each(&:disable!)
  end

  def enabled?
    !disabled
  end

  def use_options?
    %w(checkbox radio select).include?(kind)
  end

  class Entity < Grape::Entity
    expose :id
    expose :disabled
    expose :title
    expose :kind
    expose :size
    expose :inventory_section_id
    expose :available_values
    expose :field_options
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
    generate_title if title.nil? && label.present?
  end

  def generate_title
    generated_title = label.unaccented.downcase
    generated_title = generated_title.gsub(/\W/, '_')
    generated_title = "field_#{generated_title}"

    i = 0
    begin
      if i > 0
        self.title = "#{generated_title}_#{i}"
      else
        self.title = "#{generated_title}"
      end
      i += 1
    end while self.class.find_by(inventory_section_id: inventory_section_id, title: title)

    true
  end
end
