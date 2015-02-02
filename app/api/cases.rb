module Cases
  class API < Grape::API
    helpers CaseHelper
    resources :cases do
      desc 'Create a Case'
      params do
        requires :step_id,         type: Integer, desc: 'Step ID'
        requires :initial_flow_id, type: Integer, desc: 'ID of Initial Flow'
        optional :fields,          type: Array,   desc: 'Array of hash with if of field and value'
      end
      post do
        authenticate!
        step = Step.active.find(safe_params[:step_id])
        initial_flow     = Flow.find_by(id: safe_params[:initial_flow_id], initial: true)
        validate_permission!(:create, initial_flow.cases.build.case_steps.build(step: step))

        if safe_params[:fields].present?
          fields = safe_params[:fields].map { |field| {field_id: field['id'].to_i, value: field['value'].to_s} }
          case_step_params = {created_by: current_user, responsible_user_id: current_user.id, step: step,
                              step_version: step.last_version}.merge(case_step_data_fields_attributes: fields)
          kase = initial_flow.cases.create!(created_by: current_user, case_steps_attributes: [case_step_params],
                                            flow_version: initial_flow.last_version)
        else
          kase = initial_flow.cases.create!(created_by: current_user, flow_version: initial_flow.last_version)
        end
        kase.log!('create_case', user: current_user)

        trigger_result = fields.present? && step.triggers.present? ? run_triggers(step, kase, current_user) : {}
        { message: I18n.t(:case_created), case: Case::Entity.represent(kase, display_type: 'full'),
          trigger_type: trigger_result[:type], trigger_values: trigger_result[:value], trigger_description: trigger_result[:description] }
      end

      desc 'Get all Cases'
      params do
        optional :initial_flow_id,      type: String,  desc: 'String with of Initial Flows ID'
        optional :responsible_user_id,  type: String,  desc: 'String with of Users ID'
        optional :responsible_group_id, type: String,  desc: 'String with of Groups ID'
        optional :created_by_id,        type: String,  desc: 'String with of Users ID'
        optional :updated_by_id,        type: String,  desc: 'String with of Users ID'
        optional :step_id,              type: String,  desc: 'String with of Steps ID'
        optional :completed,            type: Boolean, desc: 'true to filter Case with status == "finished"'
        optional :display_type,         type: String,  desc: 'Display type for Case'
        optional :just_user_can_view,   type: Boolean, desc: 'To return all items or only title because user can\'t view (true by default)'
      end
      paginate per_page: 25
      get do
        authenticate!
        parameters = {}
        parameters[:initial_flow_id]      = safe_params[:initial_flow_id].split(',').map(&:to_i)       if safe_params[:initial_flow_id].present?
        parameters[:responsible_user_id]  = safe_params[:responsible_user_id].split(',').map(&:to_i)   if safe_params[:responsible_user_id].present?
        parameters[:responsible_group_id] = safe_params[:responsible_group_id].split(',').map(&:to_i)  if safe_params[:responsible_group_id].present?
        parameters[:created_by_id]        = safe_params[:created_by_id].split(',').map(&:to_i)         if safe_params[:created_by_id].present?
        parameters[:updated_by_id]        = safe_params[:updated_by_id].split(',').map(&:to_i)         if safe_params[:updated_by_id].present?
        parameters[:step_id]              = safe_params[:step_id].split(',').map(&:to_i)               if safe_params[:step_id].present?
        parameters[:status]               = safe_params[:completed] ? "= 'finished'" : "!= 'finished'" if safe_params[:completed].present?

        case_query = []
        case_query.push("initial_flow_id IN (#{parameters[:initial_flow_id].join(',')})") if parameters.has_key? :initial_flow_id
        case_query.push("status #{parameters[:status]}") if parameters.has_key? :status

        kases = Case.where(case_query.join(' and '))
        if parameters.has_key?(:step_id) or parameters.has_key?(:responsible_group_id) \
          or parameters.has_key?(:responsible_user_id) or parameters.has_key?(:updated_by_id) or parameters.has_key?(:created_by_id)
          case_steps_params = parameters.slice(:step_id, :responsible_group_id, :responsible_user_id, :updated_by_id, :created_by_id)
          kases = kases.select do |kase|
            kase.case_steps = kase.case_steps.where(case_steps_params)
            kase.case_steps.any?
          end
        end
        { cases: Case::Entity.represent(paginate(kases), display_type: safe_params[:display_type], just_user_can_view: (safe_params[:just_user_can_view] || true), current_user: current_user) }
      end

      resources ':id' do
        desc 'Get Case'
        params do
          optional :display_type,       type: String,  desc: 'Display type for Case'
          optional :just_user_can_view, type: Boolean, desc: 'To return all items or only title because user can\'t view (true by default)'
        end
        get do
          authenticate!
          kase = Case.not_inactive.find(safe_params[:id])
          validate_permission!(:show, kase)

          { case: Case::Entity.represent(kase, display_type: safe_params[:display_type], just_user_can_view: (safe_params[:just_user_can_view] || true), current_user: current_user) }
        end

        desc 'Inactive Case'
        delete do
          authenticate!
          kase = Case.active.find(safe_params[:id])
          validate_permission!(:delete, kase)

          kase.update!(old_status: kase.status, status: 'inactive', updated_by: current_user)
          kase.log!('delete_case', user: current_user)

          { message: I18n.t(:case_deleted) }
        end

        desc 'Restore Case'
        put '/restore' do
          authenticate!
          kase = Case.inactive.find(safe_params[:id])
          validate_permission!(:restore, kase)

          kase.update!(status: kase.old_status, old_status: nil, updated_by: current_user)
          kase.log!('restored_case', user: current_user)

          { message: I18n.t(:case_restored) }
        end

        desc 'Update Case'
        params do
          requires :step_id,      type: Integer, desc: 'Step ID'
          requires :step_version, type: Integer, desc: 'Step Version'
          optional :fields,       type: Array,   desc: 'Array of hash with if of field and value'
        end
        put do
          authenticate!
          kase = Case.not_inactive.find(safe_params[:id])
          return error!(I18n.t(:case_is_finished), 405) if kase.status == 'finished'
          return error!(I18n.t(:step_is_disabled), 400) if kase.disabled_steps.include? safe_params[:step_id]

          case_step = kase.case_steps.find_by(step_id: safe_params[:step_id])
          fields    = safe_params[:fields].present? ? safe_params[:fields].map { |field| {field_id: field['id'].to_i, value: field['value'].to_s} } : []
          if case_step.present?
            validate_permission!(:update, case_step)
            return error!(I18n.t(:version_not_equal_actual), 400) if case_step.step_version != safe_params[:step_version].to_i
            fields.each { |f| case_step.case_step_data_fields.find_or_initialize_by(field_id: f[:field_id]).update!(value: f[:value]) }
            case_step.update!(updated_by: current_user)
            step = case_step.my_step
          else
            step = Step.active.find(safe_params[:step_id]).version(safe_params[:step_version])
            case_step = kase.case_steps.build({created_by: current_user, step: step, step_version: step.last_version,
                                               responsible_user_id: current_user.id, case_step_data_fields_attributes: fields})
            validate_permission!(:create, case_step)
          end
          all_steps = kase.initial_flow.list_all_steps
          return error!(I18n.t(:step_is_not_of_case), 400) unless all_steps.present? and all_steps.map(&:id).include? step.id

          kase.updated_by  = current_user
          case_step_is_new = case_step.new_record?
          kase.save!
          if case_step_is_new and case_step.case_step_data_fields.blank?
            kase.log!('started_step', user: current_user)
            message = I18n.t(:started_step_success)
          elsif case_step_is_new
            kase.log!('next_step', user: current_user)
            message = I18n.t(:next_step_success)
          else
            kase.log!('update_step', user: current_user)
            message = I18n.t(:update_step_success)
          end
          step_index  = all_steps.index(step)
          other_steps = all_steps[step_index+1..-1]
          if other_steps.blank?
            kase.update!(status: 'finished', updated_by: current_user)
            kase.log!('finished', user: current_user)
            message = I18n.t(:finished_case)
          end
          trigger_result = step.my_triggers.present? ? run_triggers(step, kase, current_user) : {}
          { message: message, case: Case::Entity.represent(kase, display_type: 'full'),
            trigger_type: trigger_result[:type], trigger_values: trigger_result[:value], trigger_description: trigger_result[:description] }
        end

        desc 'Finish Case'
        params { requires :resolution_state_id, type: Integer, desc: 'Resolution State ID' }
        put '/finish' do
          authenticate!
          kase = Case.not_inactive.find(safe_params[:id])
          return { message: I18n.t(:case_is_already_finished) } if kase.status == 'finished'
          validate_permission!(:update, kase)

          kase.update!(status: 'finished', resolution_state_id: safe_params[:resolution_state_id])
          kase.log!('finished', user: current_user)

          { message: I18n.t(:finished_case) }
        end

        desc 'Transfer Case to other Flow'
        params do
          requires :flow_id, type: Integer, desc: 'Flow ID'
          optional :display_type, type: String, desc: 'Display Type for Case'
        end
        put '/transfer' do
          authenticate!
          kase = Case.not_inactive.find(safe_params[:id])
          return error!(I18n.t(:case_is_already_transfered), 400) if kase.status == 'transfer'
          validate_permission!(:update, kase)

          initial_flow = Flow.find_by(id: safe_params[:flow_id])
          new_kase     = initial_flow.cases.create!({created_by: current_user, original_case_id: kase.id,
                                                     flow_version: initial_flow.last_version})
          kase.update!(status: 'transfer')
          kase.log!('transfer_flow', user: current_user, child_case_id: new_kase.id)
          new_kase.log!('create_case', user: current_user)

          { message: I18n.t(:case_updated), case: Case::Entity.represent(new_kase, display_type: safe_params[:display_type]) }
        end

        desc 'Get Case History'
        params { optional :display_type, type: String,  desc: 'Display type for CasesLogEntry' }
        get '/history' do
          authenticate!
          kase = Case.find(safe_params[:id])
          validate_permission!(:show, kase)

          { cases_log_entries: CasesLogEntry::Entity.represent(kase.cases_log_entries, display_type: safe_params[:display_type]) }
        end

        resources '/case_steps' do
          desc 'Update Step of Case'
          params do
            optional :responsible_user_id,  type: Integer, desc: 'User ID'
            optional :responsible_group_id, type: Integer, desc: 'Group ID'
          end
          put ':case_step_id' do
            authenticate!
            case_step = CaseStep.find(safe_params[:case_step_id])
            validate_permission!(:update, case_step)

            log_params    = {}
            before_update = case_step.dup
            case_step.update!({updated_by: current_user}.merge(safe_params.permit(:responsible_user_id, :responsible_group_id)))

            log_params.merge!(before_user_id: before_update.responsible_user_id, after_user_id: safe_params[:responsible_user_id])     if safe_params.has_key?(:responsible_user_id)
            log_params.merge!(before_group_id: before_update.responsible_group_id, after_group_id: safe_params[:responsible_group_id]) if safe_params.has_key?(:responsible_group_id)
            if safe_params.has_key?(:responsible_user_id) or safe_params.has_key?(:responsible_group_id)
              case_step.case.log!('transfer_case', log_params.merge(user: current_user))
            end

            { message: I18n.t(:case_step_updated) }
          end
        end
      end
    end
  end
end
