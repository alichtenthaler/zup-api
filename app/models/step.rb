class Step < ActiveRecord::Base
  attr_accessor :user
  has_paper_trail only: :last_version, on: :update

  KEYS_TO_CREATE_VERSION = %w{step_type child_flow fields active order_number}

  belongs_to :flow
  belongs_to :child_flow, class_name: 'Flow', foreign_key: :child_flow_id
  has_many   :triggers,   dependent: :destroy
  has_many   :fields,     dependent: :destroy
  has_many   :case_steps

  default_scope { order(:order_number) }
  scope :active, -> { where(active: true) }

  validates :title, length: {maximum: 100}, presence: true
  validates :step_type, presence: true
  validates :step_type, inclusion: {in: %w{form flow}}, allow_blank: true
  validate  :cant_use_parent_flow_on_child_flow, if: lambda { step_type == 'flow' and child_flow.present? }

  after_validation :set_child_flow_version, if: lambda { child_flow.present? }
  after_validation :set_last_version, if: :need_create_version_by_keys?
  before_create    :set_order_number
  before_save      :set_updated_by_on_flow, unless: :need_create_version_by_keys?
  after_save       :call_bump_on_initial_flow, if: :need_create_version_by_keys?
  after_save       :update_last_version_id!, unless: :last_version_id_changed?

  def self.update_order!(ids)
    ids.each_with_index { |id, index| self.find(id).update!(order_number: index + 1) }
  end

  def bump_version_cascade!(elem)
    self.update!(last_version: self.last_version + 1) if elem != self
    self.triggers.each { |t| t.bump_version_cascade! elem }
    if self.step_type == 'form'
      self.fields.each do |i|
        i.update!(last_version: i.last_version + 1) if elem != i
      end
    end
  end

  def inactive!
    get_flow.try(:verify_if_need_create_version?) ? self.update!(active: false) : self.destroy!
  end

  def my_case_steps(options={})
    case_steps.where({step_version: last_version}.merge(options))
  end

  protected
  def list_versions
    self.versions.map(&:reify) if self.versions.present?
  end

  private
  def cant_use_parent_flow_on_child_flow
    return if self.flow.blank?
    self.errors.add(:child_flow, :invalid) if self.flow.ancestors.map(&:id).include? self.child_flow.id
  end

  def set_updated_by_on_flow
    return if self.flow.blank? or user.blank?
    self.flow.update(updated_by: user)
  end

  def set_child_flow_version
    self.child_flow_version = self.child_flow.last_version
  end

  def set_order_number
    steps = self.try(:flow).try(:steps)
    self.order_number = steps.present? ? (steps.maximum(:order_number) + 1) : 1
  end

  def set_last_version
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
      return if self.try(:flow).blank?
      object = self.flow
    end
    @get_flow ||= object
  end

  def need_create_version_by_keys?
    need = false
    need = true if get_flow.try(:verify_if_need_create_version?)
    need = self.changes.keys.select{|key| KEYS_TO_CREATE_VERSION.include? key }.present? if self.persisted?
    need
  end

  def fields_id
    self.fields.any? ? self.fields.map(&:id) : []
  end

  def child_flow_id
    self.child_flow.try(:id)
  end

  class EntityVersion < Grape::Entity
    expose :id
    expose :title
    expose :step_type
    expose :child_flow, using: Flow::Entity, if: {display_type: 'full'}
    expose :child_flow_id, unless: {display_type: 'full'}
    expose :fields,        if:     {display_type: 'full'}
    expose :fields_id,     unless: {display_type: 'full'}
    expose :order_number
    expose :active
    expose :created_at, unless: {display_type: 'basic'}
    expose :updated_at, unless: {display_type: 'basic'}
    expose :last_version, unless: {display_type: 'basic'}
    expose :last_version_id, unless: {display_type: 'basic'}
  end

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :step_type
    expose :child_flow, using: Flow::Entity, if: {display_type: 'full'}
    expose :child_flow_id, unless: {display_type: 'full'}
    expose :fields,        if:     {display_type: 'full'}
    expose :fields_id,     unless: {display_type: 'full'}
    expose :order_number
    expose :active
    expose :created_at, unless: {display_type: 'basic'}
    expose :updated_at, unless: {display_type: 'basic'}
    expose :last_version, unless: {display_type: 'basic'}
    expose :last_version_id, unless: {display_type: 'basic'}
    expose :list_versions, using: Step::EntityVersion, unless: {display_type: 'basic'}
  end
end
