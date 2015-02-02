class Trigger < ActiveRecord::Base
  serialize :action_values
  attr_accessor :user
  has_paper_trail only: :last_version, on: :update

  ACTION_TYPES           = %w{enable_steps disable_steps finish_flow transfer_flow}
  KEYS_TO_CREATE_VERSION = %w{action_values action_type active}

  belongs_to :step
  has_many   :trigger_conditions, dependent: :destroy

  accepts_nested_attributes_for :trigger_conditions

  default_scope { order(:order_number) }
  scope :active, -> { where(active: true) }

  validates :title, length: { maximum: 100 }, presence: true
  validates :action_values, :trigger_conditions, presence: true
  validates :action_type, inclusion: {in: ACTION_TYPES}, presence: true

  after_validation :set_last_version, if: :need_create_version_by_keys?
  before_create    :set_order_number
  before_save      :set_updated_by_on_flow, unless: :need_create_version_by_keys?
  after_save       :call_bump_on_initial_flow, if: :need_create_version_by_keys?
  after_save       :update_last_version_id!, unless: :last_version_id_changed?

  def self.update_order!(ids, user=nil)
    ids.each_with_index { |id, index| self.find(id).update!(order_number: index + 1) }
    elem = self.find(ids.first)
    return unless elem.get_flow.try(:verify_if_need_create_version?)
    elem.update!(last_version: elem.last_version + 1, user: user)
    elem.get_flow.try(:bump_version_cascade!, elem)
  end

  def bump_version_cascade!(elem)
    self.update!(last_version: self.last_version + 1) if elem != self
    self.trigger_conditions.each do |i|
      i.update!(last_version: i.last_version + 1) if elem != i
    end
  end

  def inactive!
    get_flow.try(:verify_if_need_create_version?) ? self.update!(active: false) : self.destroy!
  end

  def my_trigger_conditions(options={})
    return trigger_conditions.where(options) if last_version.blank? or last_version > versions.count
    @my_trigger_conditions ||= trigger_conditions.where(options).map { |s| s.versions[last_version-2].try(:reify) }.compact
  end

  def get_flow(object=nil)
    if object.blank?
      return if self.try(:step).try(:flow).blank?
      object = self.step.flow
    end
    @get_flow ||= object
  end

  protected
  def list_versions
    self.versions.map(&:reify) if self.versions.present?
  end

  private
  def set_updated_by_on_flow
    return if self.step.blank? or self.step.flow.blank? or user.blank?
    self.step.flow.update(updated_by: user)
  end

  def set_order_number
    triggers = self.try(:step).try(:triggers)
    self.order_number = triggers.present? ? (triggers.maximum(:order_number) + 1) : 1
  end

  def set_last_version
    return if self.changes.blank? or self.last_version_changed? or self.last_version_id_changed?
    self.increment :last_version
  end

  def update_last_version_id!
    return if self.reload.versions.blank? or self.reload.last_version_id == self.reload.versions.last.id
    self.reload.update! last_version_id: self.versions.last.id
  end

  def call_bump_on_initial_flow
    get_flow.try(:bump_version_cascade!, self)
  end

  def need_create_version_by_keys?
    need = false
    need = true if get_flow.try(:verify_if_need_create_version?)
    need = self.changes.keys.select{|key| KEYS_TO_CREATE_VERSION.include? key }.present? if self.persisted?
    need
  end

  class EntityVersion < Grape::Entity
    expose :id
    expose :title
    expose :trigger_conditions, using: TriggerCondition::Entity
    expose :my_trigger_conditions, using: TriggerCondition::Entity
    expose :action_type
    expose :action_values
    expose :order_number
    expose :active
    expose :created_at
    expose :updated_at
    expose :last_version
    expose :last_version_id
  end

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :trigger_conditions, using: TriggerCondition::Entity
    expose :my_trigger_conditions, using: TriggerCondition::Entity
    expose :action_type
    expose :action_values
    expose :order_number
    expose :active
    expose :created_at
    expose :updated_at
    expose :last_version
    expose :last_version_id
    expose :list_versions, using: Trigger::EntityVersion
  end
end
