class TriggerCondition < ActiveRecord::Base
  serialize :values
  attr_accessor :user
  has_paper_trail only: :last_version, on: :update

  KEYS_TO_CREATE_VERSION = %w{condition_type values active}

  belongs_to :trigger
  belongs_to :field

  scope :active, -> { where(active: true) }

  validates :values, presence: true
  validates :condition_type, inclusion: {in: %w{== != > < inc}}, presence: true

  after_validation :set_last_version, if: :need_create_version_by_keys?
  after_save       :call_bump_on_initial_flow, if: :need_create_version_by_keys?
  after_save       :update_last_version_id!, unless: :last_version_id_changed?

  def inactive!
    get_flow.try(:verify_if_need_create_version?) ? self.update!(active: false) : self.destroy!
  end

  protected
  def list_versions
    self.versions.map(&:reify) if self.versions.present?
  end

  private
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
      return if self.try(:trigger).try(:step).try(:flow).blank?
      object = self.trigger.step.flow
    end
    @get_flow ||= object
  end

  def need_create_version_by_keys?
    need = false
    need = true if get_flow.try(:verify_if_need_create_version?)
    need = self.changes.keys.select{|key| KEYS_TO_CREATE_VERSION.include? key }.present? if self.persisted?
    need
  end

  class EntityVersion < Grape::Entity
    expose :id
    expose :field, using: Field::Entity
    expose :condition_type
    expose :values
    expose :last_version
    expose :last_version_id
    expose :created_at
    expose :updated_at
  end

  class Entity < Grape::Entity
    expose :id
    expose :field, using: Field::Entity
    expose :condition_type
    expose :values
    expose :last_version
    expose :last_version_id
    expose :created_at
    expose :updated_at
    expose :list_versions, using: TriggerCondition::EntityVersion
  end
end
