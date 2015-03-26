# encoding: utf-8
class Inventory::Category < Inventory::Base
  include EncodedImageUploadable
  include LikeSearchable

  has_many :sections, class_name: 'Inventory::Section',
                      foreign_key: 'inventory_category_id',
                      autosave: true,
                      dependent: :destroy
  has_many :fields, through: :sections,
                    autosave: true
  has_many :items, class_name: 'Inventory::Item', foreign_key: 'inventory_category_id', dependent: :destroy
  has_many :statuses, class_name: 'Inventory::Status', foreign_key: 'inventory_category_id'
  has_many :formulas, class_name: 'Inventory::Formula', foreign_key: 'inventory_category_id', dependent: :destroy

  has_and_belongs_to_many :reports_categories, class_name: 'Reports::Category',
                          association_foreign_key: 'reports_category_id',
                          foreign_key: 'inventory_category_id'

  belongs_to :locker, class_name: 'User'

  accepts_nested_attributes_for :statuses

  mount_uploader :icon, IconUploader
  mount_uploader :marker, MarkerUploader
  mount_uploader :pin, PinUploader

  validates :title, presence: true, uniqueness: true
  validates :icon, integrity: true, presence: true
  validates :pin, integrity: true, presence: true
  validates :marker, integrity: true, presence: true
  validates :color, presence: true, css_hex_color: true
  validates :plot_format, presence: true, inclusion: { in: %w(pin marker) }
  validates :require_item_status, inclusion: { in: [false, true] }

  before_validation :set_default_values
  before_create :create_default_sections

  accepts_encoded_file :icon, :marker, :pin
  expose_multiple_versions :icon, :marker, :pin

  scope :locked, -> { where(locked: true) }

  def entity
    Entity.new(self)
  end

  def original_icon
    icon.to_s
  end

  # Group permissions
  def permissions
    {
      groups_can_view: groups_can_view,
      groups_can_edit: groups_can_edit
    }
  end

  def groups_can_view
    Group.that_includes_permission(:inventories_items_read_only, id).map(&:id)
  end

  def groups_can_edit
    Group.that_includes_permission(:inventories_categories_edit, id).map(&:id)
  end

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :description
    expose :plot_format
    expose :pin_structure, as: :pin
    expose :marker_structure, as: :marker
    expose :icon_structure, as: :icon
    expose :require_item_status
    expose :color
    expose :original_icon
    expose :sections
    expose :locked
    expose :locker, using: User::Entity
    expose :permissions

    with_options(if: { display_type: 'full' }) do
      expose :statuses, using: Inventory::Status::Entity
    end

    expose :created_at
    expose :updated_at, if: { display_type: 'backend' }

    def sections
      # If user is given, only select sections he has
      # permission to view.
      if options[:user]
        user_permissions = UserAbility.new(options[:user])
        sections = object.sections.preload(fields: :field_options)

        unless user_permissions.can?(:manage, Inventory::Item) || user_permissions.can?(:edit, object)
          sections = sections.where(id: user_permissions.inventory_sections_visible)
        end

        Inventory::Section::Entity.represent(sections, user: options[:user])
      end
    end
  end

  class ListingEntity < Grape::Entity
    expose :id
    expose :title
  end

  protected

  def create_default_sections
    section = sections.build(title: 'Localização', required: true, location: true)
    section.fields.build(title: 'latitude',
                         label: 'Latitude',
                         required: true,
                         location: true,
                         kind: 'decimal'
                        )
    section.fields.build(title: 'longitude',
                         label: 'Longitude',
                         required: true,
                         location: true,
                         kind: 'decimal'
                        )

    section.fields.build(title: 'address',
                         label: 'Endereço',
                         location: true,
                         kind: 'text'
                        )

    section.fields.build(title: 'postal_code',
                         label: 'CEP',
                         location: true,
                         kind: 'text'
                        )

    section.fields.build(title: 'district',
                         label: 'Bairro',
                         location: true,
                         kind: 'text'
                        )

    section.fields.build(title: 'city',
                         label: 'Cidade',
                         location: true,
                         kind: 'text'
                        )

    section.fields.build(title: 'state',
                         label: 'Estado',
                         location: true,
                         kind: 'text'
                        )

    section.fields.build(title: 'codlog',
                         label: 'Codlog',
                         location: true,
                         kind: 'text'
                        )

    section.fields.build(title: 'road_classification',
                         label: 'Classificação Viária',
                         location: true,
                         kind: 'text'
                        )
  end

  def set_default_values
    self.require_item_status = false if require_item_status.nil?

    true
  end
end
