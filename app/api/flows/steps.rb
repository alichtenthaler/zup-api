module Flows::Steps
  class API < Grape::API
    resources ':flow_id/steps' do
      desc 'List of Steps'
      params { optional :display_type, type: String, desc: 'Display type for Step' }
      get do
        authenticate!
        validate_permission!(:view, Step)
        { steps: Step::Entity.represent(Flow.find(safe_params[:flow_id]).steps, display_type: safe_params[:display_type]) }
      end

      desc 'Update order of Steps'
      params { requires :ids, type: Array, desc: 'Array with steps ids in order' }
      put do
        authenticate!
        validate_permission!(:update, Step)

        Flow.find(safe_params[:flow_id]).steps.update_order!(safe_params[:ids], current_user)
        { message: I18n.t(:steps_order_updated) }
      end

      desc 'Create a Step'
      params do
        requires :title,              type: String,  desc: 'Title of resolution state'
        optional :step_type,          type: String,  desc: 'Type of step (form or flow)'
        optional :child_flow_id,      type: Integer, desc: 'Child Flow id'
        optional :child_flow_version, type: Integer, desc: 'Child Flow Version'
      end
      post do
        authenticate!
        validate_permission!(:create, Step)

        parameters = safe_params.permit(:title, :step_type, :child_flow_id, :child_flow_version).merge(user: current_user)
        step       = Flow.find(safe_params[:flow_id]).steps.create!(parameters)
        { message: I18n.t(:step_created), step: Step::Entity.represent(step, display_type: 'full') }
      end

      desc 'Update a Step'
      params do
        requires :title,              type: String,  desc: 'Title of resolution state'
        optional :step_type,          type: String,  desc: 'Type of step (form or flow)'
        optional :child_flow_id,      type: Integer, desc: 'Child Flow id'
        optional :child_flow_version, type: Integer, desc: 'Child Flow Version'
      end
      put ':id' do
        authenticate!
        validate_permission!(:update, Step)

        parameters = safe_params.permit(:title, :step_type, :child_flow_id, :child_flow_version).merge(user: current_user)
        step       = Flow.find(safe_params[:flow_id]).steps.find(safe_params[:id])
        { message: I18n.t(:step_updated) } if step.update!(parameters)
      end

      desc 'Show a Step'
      params { optional :display_type, type: String, desc: 'Display type for Step' }
      get ':id' do
        authenticate!
        validate_permission!(:view, Step)

        step = Flow.find(safe_params[:flow_id]).steps.find(safe_params[:id])
        { step: Step::Entity.represent(step, display_type: safe_params[:display_type]) }
      end

      desc 'Delete a Step'
      delete ':id' do
        authenticate!
        validate_permission!(:delete, Step)

        step = Flow.find(safe_params[:flow_id]).steps.find(safe_params[:id])
        step.user = current_user
        step.inactive!
        { message: I18n.t(:step_deleted) }
      end

      desc 'Set Permissions to Step of Case'
      params do
        requires :group_ids,       type: Array,  desc: 'Array of Group IDs'
        requires :permission_type, type: String, desc: 'Permission type to change (can_execute_step, can_view_step)'
      end
      put ':id/permissions' do
        authenticate!
        validate_permission!(:manage, Flow)
        permission_type = safe_params[:permission_type]
        types           = %w{can_execute_step can_view_step}
        error!(I18n.t(:permission_type_not_included), 400) unless types.include? permission_type

        safe_params[:group_ids].each do |group_id|
          group = Group.find(group_id)
          group.permission.update(permission_type => group.permission.send(permission_type) + [safe_params[:id].to_i])
          group.save!
        end

        { message: I18n.t(:permissions_updated) }
      end

      desc 'Unset Permissions to Step of Case'
      params do
        requires :group_ids,       type: Array,  desc: 'Array of Group IDs'
        requires :permission_type, type: String, desc: 'Permission type to change (can_execute_step, can_view_step)'
      end
      delete ':id/permissions' do
        authenticate!
        validate_permission!(:manage, Flow)
        permission_type = safe_params[:permission_type]
        types           = %w{can_execute_step can_view_step}
        error!(I18n.t(:permission_type_not_included), 400) unless types.include? permission_type

        safe_params[:group_ids].each do |group_id|
          group = Group.find(group_id)
          group.permission.update(permission_type => group.permission.send(permission_type) - [safe_params[:id].to_i])
          group.save!
        end

        { message: I18n.t(:permissions_updated) }
      end

      desc 'Get specific version of Step'
      params { optional :display_type, type: String, desc: 'Display type for Step' }
      get ':id/versions/:step_version' do
        authenticate!
        validate_permission!(:view, Step)

        step = Flow.find(safe_params[:flow_id]).steps.find(safe_params[:id]).version(safe_params[:step_version].to_i)
        { step: Step::Entity.represent(step, display_type: safe_params[:display_type]) }
      end

      mount Flows::Steps::Fields::API
      mount Flows::Steps::Triggers::API
    end
  end
end
