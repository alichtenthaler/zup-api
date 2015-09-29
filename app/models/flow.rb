class Flow < ActiveRecord::Base
  attr_accessor :user
  has_paper_trail only: :just_with_build!, on: :update

  PERMISSION_TYPES = %w{flow_can_view_all_steps flow_can_execute_all_steps
                        flow_can_delete_own_cases flow_can_delete_all_cases}

  belongs_to :created_by,      class_name: 'User', foreign_key: :created_by_id
  belongs_to :updated_by,      class_name: 'User', foreign_key: :updated_by_id
  has_many :cases,             class_name: 'Case', foreign_key: :initial_flow_id
  has_many :parent_steps,      class_name: 'Step', foreign_key: :child_flow_id
  has_many :steps,             dependent: :destroy
  has_many :resolution_states, dependent: :destroy
  has_many :cases_log_entries
  has_many :cases_log_entries_as_new_flow, class_name: 'CasesLogEntry', foreign_key: :new_flow_id

  scope :active, -> { where.not(status: :inactive) }

  validates :title, :created_by, presence: true
  validates :title, length: { maximum: 100 }
  validates :description, length: { maximum: 600 }
  validates :updated_by, presence: true, on: :update
  validates :status, inclusion: %w(active pending inactive)

  after_validation :verify_if_has_resolution_state_default, if: -> { status != 'inactive' }
  before_update :set_draft, unless: -> { self.draft_changed? || self.current_version_changed? }

  def self.find_initial(id)
    find_by(initial: true, id: id)
  end

  def publish(current_user)
    user = current_user
    return if user.blank? || !draft
    transaction do
      override_old_version = versions.present? && Version.reify_last_version(self).cases_arent_using?
      resolutions_versions = resolution_states_versions.dup
      step_versions        = steps_versions.dup

      my_resolution_states(draft: true).each do |resolution|
        resolution.update!(user: user, draft: false)
        Version.build!(resolution, override_old_version)
        resolutions_versions[resolution.id.to_s] = resolution.versions.last.id
      end

      my_steps(draft: true).each do |step|
        trigger_versions = step.triggers_versions.dup
        field_versions   = step.fields_versions.dup

        step.my_triggers(draft: true).each do |trigger|
          condition_versions = trigger.trigger_conditions_versions.dup

          trigger.my_trigger_conditions(draft: true).each do |condition|
            condition.update!(user: user, draft: false)
            Version.build!(condition, override_old_version)
            condition_versions[condition.id.to_s] = condition.versions.last.id
          end

          trigger.update!(user: user, draft: false,
                          trigger_conditions_versions: condition_versions)
          Version.build!(trigger, override_old_version)
          trigger_versions[trigger.id.to_s] = trigger.versions.last.id
        end

        step.my_fields(draft: true).each do |field|
          field.update!(user: user, draft: false)
          Version.build!(field, override_old_version)
          field_versions[field.id.to_s] = field.versions.last.id
        end

        step.update!(triggers_versions: trigger_versions, fields_versions: field_versions,
                     user: user, draft: false)
        Version.build!(step, override_old_version)
        step_versions[step.id.to_s] = step.versions.last.id
      end

      update!(resolution_states_versions: resolutions_versions, steps_versions: step_versions,
                   draft: false, current_version: nil, updated_by: user)
      Version.build!(self, override_old_version)
    end
  end

  def cases_arent_using?
    not (my_cases.present? || my_steps(step_type: 'form').map(&:my_case_steps).flatten.present?)
  end

  def inactive!
    versions.present? ? update!(updated_by: user, status: :inactive) : destroy!
  end

  def my_cases(options = {})
    return [] if versions.blank?
    my_version = version || versions.last.try(:id)
    cases.where(options.merge(flow_version: my_version))
  end

  def my_steps(options = {})
    return steps.where(options) if steps_versions.blank?
    Version.where('Step', steps_versions, options)
  end

  def my_resolution_states(options = {})
    return resolution_states.where(options) if resolution_states_versions.blank?
    Version.where('ResolutionState', resolution_states_versions, options)
  end

  def the_version(param_draft = false, version_id = nil)
    return Version.reify(version_id) if version_id.present?
    return self if (param_draft && draft) || versions.blank?
    current_version.present? ? Version.reify(current_version) : previous_version
  end

  # revisar regra de versao
  def ancestors(child_flow = self)
    parents = []
    parents << child_flow
    parents << child_flow.parent_steps.map { |s| ancestors(s.flow) } if child_flow.parent_steps.present?
    parents.flatten.uniq
  end

  # revisar regra de versao
  def list_tree_steps(flow_step = self, skips = [])
    steps_children = []
    flow_step.my_steps.reject{ |s| skips.include? s.id }.each do |step|
      steps_children << { step: step, flow: step.my_child_flow, steps: (step.step_type == 'flow' ? list_tree_steps(step.my_child_flow, skips) : []) }
    end if flow_step.present? && flow_step.my_steps.present?
    steps_children
  end

  def list_all_steps(flow_step = self, skips = [])
    return @list_all_steps if @list_all_steps.present? && skips.blank?
    steps_children = []
    return steps_children if flow_step.try(:my_steps).blank?

    flow_step.my_steps.reject{ |step| skips.include? step.id }.each do |step|
      steps = step.step_type == 'flow' ? list_all_steps(step.my_child_flow, skips) : step
      steps_children.push(steps)
    end

    @list_all_steps = steps_children.flatten
  end

  def find_step_on_list(step_id)
    list_all_steps.select do |step|
      step.id == step_id.to_i
    end.first
  end

  def get_new_step_to_case(actual_step = nil, skips = [])
    all_steps = list_all_steps(self, skips)
    return all_steps.first if actual_step.blank? || all_steps.blank?
    next_step_index = all_steps.index(actual_step).try(:next)
    next_step_index && all_steps[next_step_index]
  end

  # verificar se algum lugar usa
  def find_my_step_form_on_tree(flow = self, step_id)
    found_step = nil
    flow.my_steps.each do |step|
      found_step = step if step.id == step_id.to_i
      found_step = find_my_step_form_on_tree(step.my_child_flow, step_id) if step.step_type == 'flow'
      return found_step if found_step.present?
    end
    found_step if found_step.present?
  end

  private

  def verify_if_has_resolution_state_default
    new_status  = 'pending'
    new_status  = 'active'   if persisted? && resolution_states.find_by(default: true).present?
    self.status = new_status if status != new_status
  end

  def set_draft
    self.draft = true
  end

  # used on Entity
  def list_versions
    versions.map(&:reify) if versions.present?
  end

  def total_cases
    cases_id      = my_cases.present? ? my_cases.map(&:id) : []
    step          = my_steps(step_type: 'form').first
    step_cases_id = step.present? && step.my_case_steps.present? ?
                      step.my_case_steps.map(&:case_id) : []
    (cases_id + step_cases_id).uniq.size
  end

  def steps_id
    steps_versions.to_h.keys
  end

  def permissions
    PERMISSION_TYPES.inject({}) do |permissions, permission|
      permissions[permission] = Group::Entity.represent(Group.that_includes_permission(permission, id))
      permissions
    end
  end

  def my_steps_flows
    my_steps.map do |step|
      if step.step_type == 'form'
        step
      else
        if step.my_child_flow.present?
          child_flow = step.my_child_flow.attributes.merge(my_steps: step.my_child_flow.my_steps)
        else
          child_flow = nil
        end
        step.attributes.merge(my_child_flow: child_flow)
      end
    end
  end

  def version_id
    version.try(:id)
  end

  class EntityVersion < Grape::Entity
    expose :id
    expose :title
    expose :description
    expose :initial
    expose :steps,                using: Step::Entity, if: { display_type: 'full' }
    expose :my_steps,             using: Step::Entity, if: { display_type: 'full' }
    expose :my_steps_flows,       if: { display_type: 'full' }
    expose :steps_versions
    expose :steps_id,             unless: { display_type: 'full' }
    expose :resolution_states,    using: ResolutionState::Entity
    expose :my_resolution_states, using: ResolutionState::Entity
    expose :resolution_states_versions
    expose :status
    expose :draft
    expose :total_cases
    expose :version_id
    expose :permissions,          if: { display_type: 'full' }
    expose :created_by_id,        unless: { display_type: 'full' }
    expose :updated_by_id,        unless: { display_type: 'full' }
    expose :created_by,           using: User::Entity, if: { display_type: 'full' }
    expose :updated_by,           using: User::Entity, if: { display_type: 'full' }
    expose :updated_at
    expose :created_at
  end

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :description
    expose :initial
    expose :steps,                using: Step::Entity, if: { display_type: 'full' }
    expose :my_steps,             using: Step::Entity, if: { display_type: 'full' }
    expose :my_steps_flows,       if: { display_type: 'full' }
    expose :steps_versions
    expose :steps_id,             unless: { display_type: 'full' }
    expose :resolution_states,    using: ResolutionState::Entity
    expose :my_resolution_states, using: ResolutionState::Entity
    expose :resolution_states_versions
    expose :status
    expose :draft
    expose :total_cases
    expose :version_id
    expose :permissions,          if:     { display_type: 'full' }
    expose :created_by_id,        unless: { display_type: 'full' }
    expose :updated_by_id,        unless: { display_type: 'full' }
    expose :created_by,           using: User::Entity, if: { display_type: 'full' }
    expose :updated_by,           using: User::Entity, if: { display_type: 'full' }
    expose :updated_at
    expose :created_at
    expose :list_versions, using: Flow::EntityVersion
  end
end
