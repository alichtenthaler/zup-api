class ResolutionState < ActiveRecord::Base
  attr_accessor :user
  has_paper_trail only: :last_version, on: :update

  KEYS_TO_CREATE_VERSION = %w{default active}

  belongs_to :flow
  has_many   :cases

  validates :title, uniqueness: {scope: :flow_id}, length: {maximum: 100}, presence: true
  validate :unique_by_default, if: lambda { self.default }

  scope :active, -> { where(active: true) }

  after_validation :set_last_version, if: :need_create_version_by_keys?
  before_update    :set_flow_pending_when_have_no_default_resolution
  before_save      :set_updated_by_on_flow, unless: :need_create_version_by_keys?
  after_save       :call_bump_on_initial_flow, if: :need_create_version_by_keys?
  after_save       :update_last_version_id!, unless: :last_version_id_changed?

  def inactive!
    get_flow.try(:get_parent_flow).try(:verify_if_need_create_version?) ? self.update!(active: false) : self.destroy!
  end

  protected
  def list_versions
    self.versions.map(&:reify) if self.versions.present?
  end

  private
  def set_updated_by_on_flow
    return if self.flow.blank? or user.blank?
    self.flow.update(updated_by: user)
  end

  def unique_by_default
    return if self.flow.blank?
    resolution_default = self.flow.resolution_states.where(default: true).select do |resolution|
      resolution.id != self.id
    end
    errors.add(:default, :taken) if resolution_default.present?
  end

  def set_flow_pending_when_have_no_default_resolution
    return if self.flow.blank?
    flow_status = self.flow.resolution_states.find_by(default: true).blank? ? 'pending' : 'active'
    self.flow.update(status: flow_status, updated_by: self.user) if self.flow.status != flow_status
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

  def get_flow(object=nil)
    if object.blank?
      return if self.try(:flow).blank?
      object = self.flow
    end
    @get_flow ||= object
  end

  def need_create_version_by_keys?
    need = false
    need = true if get_flow.try(:get_parent_flow).try(:verify_if_need_create_version?)
    need = self.changes.keys.select{|key| KEYS_TO_CREATE_VERSION.include? key }.present? if self.persisted?
    need
  end

  class EntityVersion < Grape::Entity
    expose :id
    expose :title
    expose :default
    expose :last_version
    expose :last_version_id
    expose :created_at
    expose :updated_at
    expose :active
  end

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :default
    expose :last_version
    expose :last_version_id
    expose :created_at
    expose :updated_at
    expose :active
    expose :list_versions, using: ResolutionState::EntityVersion
  end
end
