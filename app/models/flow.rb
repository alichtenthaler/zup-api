class Flow < ActiveRecord::Base
  attr_accessor :user
  has_paper_trail only: :last_version, on: :update

  KEYS_TO_CREATE_VERSION = %w{updated_by status parent_step}

  belongs_to :created_by,        class_name: 'User', foreign_key: :created_by_id
  belongs_to :updated_by,        class_name: 'User', foreign_key: :updated_by_id
  has_many   :cases,             class_name: 'Case', foreign_key: :initial_flow_id
  has_many   :parent_steps,      class_name: 'Step', foreign_key: :child_flow_id
  has_many   :steps,             dependent: :destroy
  has_many   :resolution_states, dependent: :destroy

  scope :active, -> { where('status != ?', :inactive) }

  validates :title, :created_by, presence: true
  validates :updated_by, presence: true, on: :update
  validates :title, length: {maximum: 100}
  validates :description, length: {maximum: 600}

  after_validation :set_last_version, if: :need_create_version_by_keys?
  after_validation :verify_if_has_resolution_state_default, if: lambda { self.status != 'inactive' }
  after_save       :call_bump_on_initial_flow, if: :need_create_version_by_keys?
  after_save       :update_last_version_id!, unless: :last_version_id_changed?

  def bump_version_cascade!(elem, skip_flow=false)
    elem = elem.reload
    return unless need_create_version_by_keys?
    unless skip_flow
      self.user = elem.user
      self.update!(last_version: self.last_version + 1, updated_by: self.user)
    end
    self.steps.each { |s| s.bump_version_cascade! elem }
    self.resolution_states.each do |i|
      i.update!(last_version: i.last_version + 1) if elem != i
    end
  end

  def verify_if_need_create_version?
    total_cases > 0
  end

  def inactive!
    verify_if_need_create_version? ? self.update!(status: :inactive) : self.destroy!
  end

  def my_cases(options={})
    cases.where({flow_version: last_version}.merge(options))
  end

  #TODO adicionar where depois do filtro de versoes
  def my_steps(options={})
    return steps.where(options) if last_version.blank? or last_version > versions.count
    steps.unscoped.where(options).map { |s| s.versions[last_version-2].try(:reify) }
  end

  def list_all_steps(flow_step=self, skips=[])
    steps_children = []
    flow_step.my_steps.reject{|s| skips.include? s.id }.each do |step|
      steps_children.push(step.step_type == 'flow' ? list_all_steps(step.child_flow) : step)
    end if flow_step.present? and flow_step.my_steps.present?
    steps_children.flatten
  end

  def list_tree_steps(flow_step=self, skips=[])
    steps_children = []
    flow_step.my_steps.reject{|s| skips.include? s.id }.each do |step|
      steps_children << {step: step, flow: step.child_flow, steps: (step.step_type == 'flow' ? list_tree_steps(step.child_flow) : [])}
    end if flow_step.present? and flow_step.my_steps.present?
    steps_children
  end

  def get_new_step_to_case(actual_step=nil, skips=[])
    all_steps = list_all_steps(self, skips) || []
    return all_steps.first if actual_step.blank? or all_steps.blank?
    actual = all_steps.index(actual_step) || 0
    all_steps[actual+1]
  end

  def ancestors(child_flow=self)
    parents = []
    parents << child_flow
    parents << child_flow.parent_steps.map { |s| ancestors(s.flow) } if child_flow.parent_steps.present?
    parents.flatten.uniq
  end

  private
  def verify_if_has_resolution_state_default
    status = 'pending'
    status = 'active'    if self.persisted? and self.resolution_states.find_by(default: true).present?
    self.status = status if self.status != status
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
    bump_version_cascade! self, true
  end

  def need_create_version_by_keys?
    need = false
    need = true if verify_if_need_create_version?
    need = self.changes.keys.select do |key|
      KEYS_TO_CREATE_VERSION.include?(key)
    end.present? if self.persisted? and self.changes.present?
    need
  end

  protected
  def list_versions
    self.versions.map(&:reify) if self.versions.present?
  end

  def total_cases
    cases_id      = my_cases.present? ? my_cases.map(&:id) : []
    step          = my_steps(step_type: 'form').first
    step_cases_id = step.present? && step.my_case_steps.present? ? step.my_case_steps.map { |cs| cs.case.id } : []
    (cases_id + step_cases_id).uniq.count
  end

  def steps_id
    self.my_steps.map(&:id)
  end

  class EntityVersion < Grape::Entity
    expose :id
    expose :title
    expose :description
    expose :initial
    expose :steps,         if:     {display_type: 'full'}
    expose :steps_id,      unless: {display_type: 'full'}
    expose :created_by_id, unless: {display_type: 'full'}
    expose :updated_by_id, unless: {display_type: 'full'}
    expose :created_by,    using: User::Entity, if: {display_type: 'full'}
    expose :updated_by,    using: User::Entity, if: {display_type: 'full'}
    expose :resolution_states
    expose :status
    expose :last_version
    expose :last_version_id
    expose :created_at
    expose :updated_at
    expose :total_cases
  end

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :description
    expose :initial
    expose :steps,           if:     {display_type: 'full'}
    expose :steps_id,        unless: {display_type: 'full'}
    expose :created_by_id,   unless: {display_type: 'full'}
    expose :updated_by_id,   unless: {display_type: 'full'}
    expose :created_by,      using: User::Entity, if: {display_type: 'full'}
    expose :updated_by,      using: User::Entity, if: {display_type: 'full'}
    expose :resolution_states
    expose :status
    expose :last_version
    expose :last_version_id
    expose :created_at
    expose :updated_at
    expose :total_cases
    expose :list_versions, using: Flow::EntityVersion
  end
end
