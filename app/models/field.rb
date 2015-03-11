class Field < ActiveRecord::Base
  include StoreAccessorTypes

  store_accessor :requirements, :presence, :minimum, :maximum
  store_accessor :values
  has_paper_trail only: :just_with_build!, on: :update

  VALID_TYPES = %w{angle date time date_time cpf cnpj url email image attachment text integer decimal
                   meter centimeter kilometer year month day hour minute second previous_field
                   radio select checkbox category_inventory category_inventory_field category_report}

  belongs_to :user
  belongs_to :step
  belongs_to :category_inventory, class_name: 'Inventory::Category', foreign_key: :category_inventory_id
  belongs_to :category_report,    class_name: 'Reports::Category',   foreign_key: :category_report_id
  has_many   :case_step_fields

  default_scope -> { order(id: :asc) }
  scope :active,    -> { where(active: true) }
  scope :requireds, -> { where("requirements -> 'presence' = 'true'") }

  validates :title, presence: true
  validates :field_type, inclusion: { in: VALID_TYPES }
  validates :origin_field_id, presence: true, if: -> { %w{previous_field category_inventory_field}.include? field_type }
  validates :values, presence: true, if: -> { %w{checkbox radio}.include? field_type }
  validate  :category_inventory_present?, if: -> { field_type == 'category_inventory_field' }

  after_create   :add_field_on_step
  before_save    :set_origin_field_version, if: :origin_field_id?
  before_update  :set_draft, unless: :draft_changed?
  before_update  :remove_step_on_flow, if: -> { active_changed? and not active }
  before_destroy :remove_step_on_flow

  def self.update_order!(ids, user = nil)
    step      = find(ids.first).step
    fields    = step.fields_versions
    order_ids = ids.inject({}) do |ids, id|
      ids[id.to_s] = fields[id.to_s]
      ids
    end
    step.update! fields_versions: {}
    step.update! fields_versions: order_ids
  end

  def inactive!
    versions.present? ? update!(active: false) : destroy!
  end

  def get_flow(object = nil)
    @get_flow ||= object || step.flow
  end

  def required?
    requirements.present? and requirements['presence'] == 'true'
  end

  private
  def category_inventory_present?
    category   = step.my_fields(field_type: 'category_inventory').first
    category ||= get_flow.my_steps(step_type: 'form').map do |step_form|
                   step_form.my_fields(field_type: 'category_inventory').first
                 end.flatten.first
    errors.add(:field_type, I18n.t(:need_set_category_inventory_before)) if category.blank?
  end

  def previous_field
    return if field_type != 'previous_field'
    origin_field_version.blank? ? Field.find_by(origin_field_id) : Version.reify(origin_field_version)
  end

  def set_origin_field_version
    return if field_type != 'previous_field' or origin_field_version.present?
    field = Field.find_by(origin_field_id)
    self.origin_field_version = field.versions.try(:last).try(:id)
  end

  def add_field_on_step
    field_versions = step.fields_versions.dup
    field_versions.merge!(id.to_s => nil)
    step.update! user: user, fields_versions: {}
    step.update! user: user, fields_versions: field_versions
  end

  def set_draft
    get_flow.update! updated_by: user, draft: true
    self.draft = true
  end

  def remove_step_on_flow
    field_versions = step.fields_versions.dup
    field_versions.delete(id.to_s)
    step.update! user: user, fields_versions: {}
    step.update! user: user, fields_versions: field_versions
  end

  # used on Entity
  def list_versions
    versions.map(&:reify) if versions.present?
  end

  def version_id
    version.try(:id)
  end

  class EntityVersion < Grape::Entity
    expose :id
    expose :title
    expose :field_type
    expose :filter
    expose :origin_field_id
    expose :category_inventory
    expose :category_report
    expose :requirements
    expose :values
    expose :active
    expose :version_id
    expose :updated_at
    expose :created_at
    expose :previous_field, using: Field::EntityVersion
  end

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :field_type
    expose :filter
    expose :origin_field_id
    expose :category_inventory
    expose :category_report
    expose :requirements
    expose :values
    expose :active
    expose :version_id
    expose :updated_at
    expose :created_at
    expose :previous_field, using: Field::EntityVersion
    expose :list_versions,  using: Field::EntityVersion
  end
end
