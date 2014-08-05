class Field < ActiveRecord::Base
  include StoreAccessorTypes

  attr_accessor  :user
  store_accessor :requirements, :presence, :minimum, :maximum
  store_accessor :values
  has_paper_trail only: :last_version, on: :update

  VALID_TYPES = %w{angle date time date_time cpf cnpj url email image attachment text integer decimal
                   meter centimeter kilometer year month day hour minute second previous_field
                   radio select checkbox category_inventory category_inventory_field category_report}

  KEYS_TO_CREATE_VERSION = %w{field_type requirements active order_number values}

  belongs_to :step
  belongs_to :category_inventory, class_name: 'Inventory::Category', foreign_key: :category_inventory_id
  belongs_to :category_report,    class_name: 'Reports::Category',   foreign_key: :category_report_id
  has_many   :case_step_fields

  default_scope { order(:order_number) }
  scope :active, -> { where(active: true) }

  validates :title, presence: true
  validates :field_type, inclusion: { in: VALID_TYPES }
  validates :origin_field_id, presence: true, if: lambda { %w{previous_field category_inventory_field}.include? self.field_type }
  validates :values, presence: true, if: lambda { %w{checkbox radio}.include? self.field_type }
  validate  :category_inventory_present?, if: lambda { self.field_type == 'category_inventory_field' }

  after_validation :set_last_version, if: :need_create_version_by_keys?
  before_create    :set_order_number
  before_save      :set_updated_by_on_flow, unless: :need_create_version_by_keys?
  after_save       :call_bump_on_initial_flow, if: :need_create_version_by_keys?
  after_save       :update_last_version_id!, unless: :last_version_id_changed?

  def self.update_order!(ids)
    ids.each_with_index { |id, index| self.find(id).update!(order_number: index + 1) }
  end

  def inactive!
    get_flow.try(:verify_if_need_create_version?) ? self.update!(active: false) : self.destroy!
  end

  private
  def category_inventory_present?
    category = self.step.fields.find_by(field_type: 'category_inventory')
    if category.blank?
      category = self.step.flow.steps.map do |flow_step|
        flow_step.fields.find_by(field_type: 'category_inventory') if flow_step.step_type == 'form'
      end.flatten.first
    end
    self.errors.add(:field_type, I18n.t(:need_set_category_inventory_before)) if category.blank?
  end

  def set_updated_by_on_flow
    return if self.step.blank? or self.step.flow.blank? or user.blank?
    self.step.flow.update(updated_by: user)
  end

  def set_order_number
    fields = self.try(:step).try(:fields)
    self.order_number = fields.present? ? (fields.maximum(:order_number) + 1) : 1
  end

  def set_last_version
    if self.new_record? and need_create_version_by_keys?
      self.last_version = get_flow.try(:last_version)
      return
    end
    return if self.last_version_changed? or self.last_version_id_changed?
    self.increment :last_version
  end

  def update_last_version_id!
    return if self.reload.versions.blank? or self.reload.last_version_id == self.reload.versions.last.id
    self.reload.update! last_version_id: self.versions.last.id
  end

  def call_bump_on_initial_flow
    get_flow.try(:bump_version_cascade!, self)
  end

  def get_flow(object=nil)
    if object.blank?
      return if self.try(:step).try(:flow).blank?
      object = self.step.flow
    end
    @get_flow ||= object
  end

  def need_create_version_by_keys?
    need = false
    need = true if get_flow.try(:verify_if_need_create_version?)
    need = self.changes.keys.select{|key| KEYS_TO_CREATE_VERSION.include? key }.present? if self.persisted?
    need
  end

  def previous_field
    Field.find_by(self.origin_field_id) if self.field_type == 'previous_field'
  end

  protected
  def list_versions
    self.versions.map(&:reify) if self.versions.present?
  end

  class EntityVersion < Grape::Entity
    expose :id
    expose :title
    expose :field_type
    expose :filter
    expose :origin_field_id
    expose :category_inventory
    expose :order_number
    expose :category_report
    expose :requirements
    expose :values
    expose :active
    expose :created_at
    expose :updated_at
    expose :last_version
    expose :last_version_id
    expose :previous_field, using: Field::EntityVersion
  end

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :field_type
    expose :filter
    expose :origin_field_id
    expose :category_inventory
    expose :order_number
    expose :category_report
    expose :requirements
    expose :values
    expose :active
    expose :created_at
    expose :updated_at
    expose :last_version
    expose :last_version_id
    expose :previous_field, using: Field::EntityVersion
    expose :list_versions,  using: Field::EntityVersion
  end
end
