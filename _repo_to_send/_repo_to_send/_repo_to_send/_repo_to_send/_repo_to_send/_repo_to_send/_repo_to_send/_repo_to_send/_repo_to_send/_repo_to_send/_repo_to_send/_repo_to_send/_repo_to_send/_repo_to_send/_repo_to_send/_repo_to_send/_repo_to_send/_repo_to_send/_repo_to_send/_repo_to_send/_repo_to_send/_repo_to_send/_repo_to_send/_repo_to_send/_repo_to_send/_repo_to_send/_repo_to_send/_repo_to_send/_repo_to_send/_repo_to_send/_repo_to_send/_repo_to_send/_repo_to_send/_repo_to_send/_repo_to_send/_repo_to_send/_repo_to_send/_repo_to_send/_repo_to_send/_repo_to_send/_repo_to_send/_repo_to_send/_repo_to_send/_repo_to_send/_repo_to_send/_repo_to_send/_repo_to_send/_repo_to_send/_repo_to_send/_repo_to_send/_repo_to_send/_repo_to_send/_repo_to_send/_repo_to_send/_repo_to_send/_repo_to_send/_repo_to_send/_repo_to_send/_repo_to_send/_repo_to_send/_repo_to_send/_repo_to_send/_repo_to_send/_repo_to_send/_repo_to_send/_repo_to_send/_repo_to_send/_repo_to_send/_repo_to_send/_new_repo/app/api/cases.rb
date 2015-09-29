module Cases
  class API < Grape::API
    helpers CaseHelper

    resources :cases do
      desc 'Create a Case'
      params do
        requires :initial_flow_id,      type: Integer, desc: 'ID of Initial Flow'
        optional :fields,               type: Array,   desc: 'Array of hash with id of field and value'
        optional :responsible_user_id,  type: Integer, desc: 'Responsible User ID'
        optional :responsible_group_id, type: Integer, desc: 'Responsible Group ID'
      end
      post do
        authenticate!
        initial_flow = Flow.find_initial(safe_params[:initial_flow_id]).the_version
        step = initial_flow.get_new_step_to_case
        return error!(I18n.t(:flow_not_published), 400) if initial_flow.version.blank?
        return error!(I18n.t(:step_not_found), 404)     unless step.try(:active)
        validate_permission!(:create, initial_flow.cases.build.case_steps.build(step: step))

        case_step_params = { created_by: current_user, step: step, step_version: step.version.id }
        if safe_params[:fields].present?
          case_step_params.merge!(responsible_user_id: current_user.id,
                                  case_step_data_fields_attributes: fields_params)
        else
          if safe_params[:responsible_user_id].present?
            case_step_params.merge!(responsible_user_id: safe_params[:responsible_user_id])
          elsif safe_params[:responsible_group_id].present?
            case_step_params.merge!(responsible_group_id: safe_params[:responsible_group_id])
          else
            case_step_params.merge!(responsible_user_id: current_user.id)
          end
        end

        kase = initial_flow.cases.create!(created_by: current_user,
                                          case_steps_attributes: [case_step_params],
                                          flow_version: initial_flow.version.id)
        kase.log!('create_case', user: current_user)

        trigger_result = run_triggers(step, kase)

        { message: I18n.t(:case_created), case: Case::Entity.represent(kase, only: return_fields, display_type: 'full'),
         trigger_type: trigger_result[:type], trigger_values: trigger_result[:value],
         trigger_description: trigger_result[:description] }
      end

      desc 'Get all Cases'
      params do
        optional :initial_flow_id,      type: String,  desc: 'String with of Initial Flows ID, split by comma'
        optional :initial_flow_version, type: String,  desc: 'String with of Initial Flows ID, split by comma'
        optional :responsible_user_id,  type: String,  desc: 'String with of Users ID, split by comma'
        optional :responsible_group_id, type: String,  desc: 'String with of Groups ID, split by comma'
        optional :created_by_id,        type: String,  desc: 'String with of Users ID, split by comma'
        optional :updated_by_id,        type: String,  desc: 'String with of Users ID, split by comma'
        optional :step_id,              type: String,  desc: 'String with of Steps ID, split by comma'
        optional :completed,            type: Boolean, desc: 'true to filter Case with status == "finished"'
        optional :display_type,         type: String,  desc: 'Display type for Case'
        optional :just_user_can_view,   type: Boolean, desc: 'To return all items or only title because user can\'t view (true by default)'
      end
      paginate per_page: 25
      get do
        authenticate!
        parameters = filter_params

        case_query = []
        if parameters[:initial_flow_id].present?
          case_query.push('initial_flow_id IN (:initial_flow_id)')
        end
        if parameters[:initial_flow_version].present?
          case_query.push('flow_version IN (:initial_flow_version)')
        end
        if safe_params.has_key? :completed
          status = safe_params[:completed] ? "= 'finished'" : "!= 'finished'"
          case_query.push("status #{status}")
        end

        kases = Case.where(case_query.join(' and '), parameters.to_h)
        if parameters[:step_id].present? || parameters[:responsible_group_id].present?  ||
            parameters[:responsible_user_id].present? ||
            parameters[:updated_by_id].present? || parameters[:created_by_id].present?

          case_steps_params = parameters.slice(:step_id, :responsible_group_id,
                                               :responsible_user_id,
                                               :updated_by_id, :created_by_id)
          case_steps_params.reject! { |_key, value| value.blank? }
          kases = kases.select do |kase|
            kase.case_steps = kase.case_steps.where(case_steps_params)
            kase.case_steps.any?
          end
        end

        { cases: Case::Entity.represent(paginate(kases), only: return_fields, display_type: safe_params[:display_type],
                                       just_user_can_view: (safe_params[:just_user_can_view] || true),
                                       current_user: current_user) }
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

          { case: Case::Entity.represent(kase, only: return_fields, display_type: safe_params[:display_type],
                                        just_user_can_view: (safe_params[:just_user_can_view] || true),
                                        current_user: current_user) }
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

        desc 'Update/Next Step Case'
        params do
          requires :step_id,              type: Integer, desc: 'Step ID'
          optional :fields,               type: Array,   desc: 'Array of hash with if of field and value'
          optional :responsible_user_id,  type: Integer, desc: 'Responsible User ID'
          optional :responsible_group_id, type: Integer, desc: 'Responsible Group ID'
        end
        put do
          authenticate!
          kase = Case.not_inactive.find(safe_params[:id])
          return error!(I18n.t(:case_is_finished), 405) if kase.status == 'finished'
          return error!(I18n.t(:step_is_disabled), 400) if kase.disabled_steps.include? safe_params[:step_id]
          step = kase.initial_flow.find_step_on_list(safe_params[:step_id])
          return error!(I18n.t(:step_is_not_of_case), 400) if step.blank?

          case_step = kase.case_steps.find_by(step_id: safe_params[:step_id])
          fields    = fields_params
          if case_step.present?
            validate_permission!(:update, case_step)
            fields.each do |field|
              case_step.case_step_data_fields.
                find_or_initialize_by(field_id: field[:field_id]).update!(value: field[:value])
            end
            case_step.update!(responsible_user_id: current_user.id, updated_by: current_user)
          else
            case_step_params = { created_by: current_user, step: step, step_version: step.version.id,
                                case_step_data_fields_attributes: fields }
            if safe_params[:responsible_user_id].present?
              case_step_params.merge!(responsible_user_id: safe_params[:responsible_user_id])
            elsif safe_params[:responsible_group_id].present?
              case_step_params.merge!(responsible_group_id: safe_params[:responsible_group_id])
            else
              case_step_params.merge!(responsible_user_id: current_user.id)
            end
            case_step = kase.case_steps.build(case_step_params)
            validate_permission!(:create, case_step)

            current_step = kase.case_steps.last
            if current_step.present? && current_step.id != step.id &&
                !(current_step.executed? || current_step.my_step.required_fields.blank?) &&
                !kase.disabled_steps.include?(current_step.id)
              return error!(I18n.t(:current_step_required), 400)
            end
          end

          kase.updated_by  = current_user
          case_step_is_new = case_step.new_record?
          kase.save!
          if case_step_is_new && case_step.case_step_data_fields.blank?
            kase.log!('started_step', user: current_user)
            message = I18n.t(:started_step_success)
          elsif case_step_is_new
            kase.log!('next_step', user: current_user)
            message = I18n.t(:next_step_success)
          else
            kase.log!('update_step', user: current_user)
            message = I18n.t(:update_step_success)
          end
          all_steps       = kase.initial_flow.list_all_steps
          next_step_index = all_steps.index(step).try(:next)
          next_steps      = all_steps[next_step_index..-1]
          if kase.status == 'not_satisfied' || next_steps.blank?
            if kase.steps_not_fulfilled.blank?
              kase.update!(status: 'finished', updated_by: current_user)
              kase.log!('finished', user: current_user)
              message = I18n.t(:finished_case)
            else
              kase.update!(status: 'not_satisfied', updated_by: current_user)
              kase.log!('not_satisfied', user: current_user)
              message = I18n.t(:case_with_pending_steps)
            end
          end

          trigger_result = run_triggers(step, kase)
          { message: message, case: Case::Entity.represent(kase, only: return_fields, display_type: 'full'),
           trigger_type: trigger_result[:type], trigger_values: trigger_result[:value],
           trigger_description: trigger_result[:description] }
        end

        desc 'To Finish Case'
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
          requires :flow_id,      type: Integer, desc: 'Flow ID'
          optional :display_type, type: String,  desc: 'Display Type for Case'
        end
        put '/transfer' do
          authenticate!
          kase = Case.not_inactive.find(safe_params[:id])
          return error!(I18n.t(:case_is_already_transfered), 400) if kase.status == 'transfer'
          validate_permission!(:update, kase)

          initial_flow = Flow.find_by(id: safe_params[:flow_id]).the_version
          new_kase     = initial_flow.cases.create!(created_by: current_user, original_case_id: kase.id,
                                                    flow_version: initial_flow.version.id)
          kase.update!(status: 'transfer')
          kase.log!('transfer_flow', user: current_user, child_case_id: new_kase.id)
          new_kase.log!('create_case', user: current_user)

          { message: I18n.t(:case_updated),
            case: Case::Entity.represent(new_kase, only: return_fields, display_type: safe_params[:display_type]) }
        end

        desc 'Get Case History'
        params { optional :display_type, type: String,  desc: 'Display type for CasesLogEntry' }
        get '/history' do
          authenticate!
          kase = Case.find(safe_params[:id])
          validate_permission!(:show, kase)

          { cases_log_entries: CasesLogEntry::Entity.represent(kase.cases_log_entries, only: return_fields,
                                                              display_type: safe_params[:display_type]) }
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
            parameters    = safe_params.permit(:responsible_user_id, :responsible_group_id)
            case_step.update!({ updated_by: current_user }.merge(parameters))

            if safe_params.has_key?(:responsible_user_id)
              log_params.merge!(before_user_id: before_update.responsible_user_id,
                                after_user_id: safe_params[:responsible_user_id])
            end
            if safe_params.has_key?(:responsible_group_id)
              log_params.merge!(before_group_id: before_update.responsible_group_id,
                                after_group_id: safe_params[:responsible_group_id])
            end
            if safe_params.has_key?(:responsible_user_id) || safe_params.has_key?(:responsible_group_id)
              case_step.case.log!('transfer_case', log_params.merge(user: current_user))
            end

            { message: I18n.t(:case_step_updated) }
          end
        end
      end
    end
  end
end
