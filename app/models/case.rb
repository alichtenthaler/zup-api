class Case < ActiveRecord::Base
  has_many :cases_log_entries
  has_many :case_steps
  belongs_to :initial_flow,     class_name: 'Flow',            foreign_key: :initial_flow_id
  belongs_to :created_by,       class_name: 'User',            foreign_key: :created_by_id
  belongs_to :updated_by,       class_name: 'User',            foreign_key: :updated_by_id
  belongs_to :resolution_state, class_name: 'ResolutionState', foreign_key: :resolution_state_id
  belongs_to :original_case,    class_name: 'Case',            foreign_key: :original_case_id
  has_many :children_cases,   class_name: 'Case',            foreign_key: :original_case_id

  accepts_nested_attributes_for :case_steps

  scope :active,        -> { where(status: %w{active pending transfer not_satisfied}) }
  scope :not_inactive,  -> { where.not(status: 'inactive') }
  scope :inactive,      -> { where(status: 'inactive') }
  scope :not_inactive_and_transfered, -> { where.not(status: ['inactive', 'transfer']) }

  validates :created_by_id, :initial_flow_id, presence: true
  validates :status, inclusion: { in: %w{active pending finished inactive transfer not_satisfied} }
  validate :not_change_initial_flow, on: :update

  def log!(action, options = {})
    basic = { flow: initial_flow, flow_version: flow_version, user: created_by,
             step: case_steps.last.try(:my_step), action: action }
    cases_log_entries.create! options.merge(basic)
  end

  def responsible_user_id
    get_responsible_user.try(:id)
  end

  def responsible_group_id
    get_responsible_group.try(:id)
  end

  def next_step
    actual_step = case_steps.try(:last)
    return actual_step.step if actual_step.present? && actual_step.case_step_data_fields.blank?
    my_initial_flow.get_new_step_to_case(actual_step.try(:my_step), disabled_steps)
  end

  def steps_not_fulfilled
    my_initial_flow.list_all_steps(my_initial_flow, disabled_steps).reject do |step|
      step.my_case_steps(case_id: id).first.try(:executed?) || step.required_fields.blank?
    end.map(&:id)
  end

  private

  def my_initial_flow
    Version.reify(flow_version)
  end

  def not_change_initial_flow
    initial_flow_id_changed? && errors.add(:initial_flow, :changed)
  end

  def total_steps
    initial_flow.list_all_steps.size
  end

  def next_step_id
    next_step.try(:id)
  end

  def children_case_id
    children_cases.pluck(:id).first
  end

  def get_responsible_user
    case_steps.last.try(:responsible_user) || responsible_user
  end

  def get_responsible_group
    case_steps.last.try(:responsible_group) || responsible_group
  end

  class Entity < Grape::Entity
    def previous_steps(instance, options = {})
      case_step_ids = []
      case_steps    = instance.case_steps.reject{ |cs| cs.id == instance.case_steps.last.id }
      if options[:just_user_can_view]
        @permissions ||= UserAbility.new(options[:current_user])
        case_steps = case_steps.map do |case_step|
          case_step unless @permissions.can?(:show, case_step.step)
        end.compact if instance.case_steps.count > 1
        case_step_ids = case_steps.map(&:id) if case_steps.present?
      end
      CaseStep::Entity.represent case_steps, options.merge(simplify_to: case_step_ids)
    end

    def select_steps_that_user_can_see(steps)
      steps.map do |step|
        if @permissions.can?(:show, step[:step])
          step[:flow_steps] = select_steps_that_user_can_see(step[:flow_steps]) if step[:flow_steps].present?
          step
        else
          step[:step] = step[:step].slice(:id, :title, :step_type)
          step[:flow] = step[:flow].slice(:id, :title) if step[:flow].present?
          step[:flow_steps] = select_steps_that_user_can_see(step[:flow_steps]) if step[:flow_steps].present?
          step
        end
      end
      steps
    end

    def case_step_ids(instance, options)
      case_step_ids = instance.case_steps.map(&:id)
      if options[:just_user_can_view]
        @permissions ||= UserAbility.new(options[:current_user])
        case_steps = instance.case_steps.map do |case_step|
          case_step_ids -= [case_step.id] unless @permissions.can?(:show, case_step.step)
        end.compact if instance.case_steps.any?
      end
      case_step_ids
    end

    def case_steps(instance, options)
      case_step_ids = []
      if options[:just_user_can_view]
        @permissions ||= UserAbility.new(options[:current_user])
        case_steps = instance.case_steps.map do |case_step|
          case_step unless @permissions.can?(:show, case_step.step)
        end.compact if instance.case_steps.any?
        case_step_ids = case_steps.map(&:id) if case_steps.present?
      end
      CaseStep::Entity.represent instance.case_steps, options.merge(simplify_to: case_step_ids)
    end

    def current_step(instance, options = {})
      case_step = instance.case_steps.last
      if options[:just_user_can_view] && case_step.present?
        @permissions ||= UserAbility.new(options[:current_user])
        case_step_ids = case_step.id unless @permissions.can?(:show, case_step.step)
      end
      CaseStep::Entity.represent case_step, options.merge(simplify_to: case_step_ids)
    end

    def next_steps(instance, options = {})
      old_steps   = instance.case_steps.present? ? instance.case_steps.map { |cs| cs.step.id } : []
      skip_steps  = old_steps + instance.disabled_steps
      steps       = instance.initial_flow.list_all_steps(instance.initial_flow, skip_steps)
      Step::Entity.represent steps, options
    end

    def list_tree_steps(instance, _options = {})
      instance.initial_flow.list_tree_steps(instance.initial_flow)
    end

    def change_options_to_return_fields(key, options = {})
      return options if options[:only].blank?
      fields = options[:only].select { |field| field.is_a?(Hash) && field[key].present? }
      fields.present? && options.merge!(only: fields.first[key])
      options
    end

    expose :id
    expose :created_by_id
    expose :updated_by_id
    expose :created_at
    expose :updated_at
    expose :initial_flow_id
    expose :flow_version
    expose :total_steps
    expose :disabled_steps
    expose :original_case_id
    expose :children_case_id
    expose :case_step_ids do |instance, options|
      case_step_ids(instance, change_options_to_return_fields(:case_step_ids, options))
    end
    expose :next_step_id
    expose :responsible_user_id
    expose :responsible_group_id
    expose :status
    expose :steps_not_fulfilled
    expose :completed do |instance, _options|
      instance.status == 'finished'
    end
    with_options(if: { display_type: 'full' }) do
      expose :created_by,            using: User::Entity
      expose :updated_by,            using: User::Entity
      expose :get_responsible_user,  using: User::Entity
      expose :get_responsible_group, using: Group::Entity
      expose :original_case,         using: Case::Entity
      expose :case_steps do |instance, options|
        case_steps(instance, change_options_to_return_fields(:case_steps, options))
      end
      expose :current_step do |instance, options|
        current_step(instance, change_options_to_return_fields(:current_step, options))
      end
      expose :steps do |instance, options|
        list_tree_steps(instance, change_options_to_return_fields(:steps, options))
      end
    end
  end
end
