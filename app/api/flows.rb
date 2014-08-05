module Flows
  class API < Grape::API
    resources :flows do
      desc 'List of all flows'
      params do
        optional :initial,      type: Boolean, desc: 'Filter by Initial Flow'
        optional :display_type, type: String,  desc: 'Display type for Flow'
      end
      get do
        authenticate!
        validate_permission!(:view, Flow)
        { flows: Flow::Entity.represent(Flow.where(safe_params.permit(:initial)), display_type: safe_params[:display_type]) }
      end

      desc 'Create a flow'
      params do
        requires :title,       type: String,  desc: 'Title of flow'
        optional :description, type: String,  desc: 'Description of flow'
        optional :initial,     type: Boolean, desc: 'If flow is initial'
      end
      post do
        authenticate!
        validate_permission!(:create, Flow)

        flow = Flow.create! safe_params.permit(:title, :description, :initial).merge(created_by: current_user)
        { message: I18n.t(:flow_created), flow: Flow::Entity.represent(flow, display_type: 'full') }
      end

      resource ':id' do
        desc 'Show a flow'
        params { optional :display_type, type: String, desc: 'Display type for Flow' }
        get do
          authenticate!
          validate_permission!(:view, Flow)

          { flow: Flow::Entity.represent(Flow.find(safe_params[:id]), display_type: safe_params[:display_type]) }
        end

        desc 'Delete a flow'
        delete do
          authenticate!
          validate_permission!(:delete, Flow)

          Flow.find(safe_params[:id]).inactive!
          { message: I18n.t(:flow_deleted) }
        end

        desc 'Update a flow'
        params do
          requires :title      , type: String , desc: 'Title of flow'
          optional :description, type: String , desc: 'Description of flow'
          optional :initial    , type: Boolean, desc: 'If flow is initial'
        end
        put do
          authenticate!
          validate_permission!(:update, Flow)
          flow_params = safe_params.permit(:title, :description, :initial)
          flow_params.merge!(updated_by: current_user)

          Flow.find(safe_params[:id]).update!(flow_params)
          { message: I18n.t(:flow_updated) }
        end

        desc 'Show ancestors of the flow'
        params { optional :display_type, type: String, desc: 'Display type for Flow' }
        get 'ancestors' do
          authenticate!
          validate_permission!(:view, Flow)

          ancestors = Flow.find(safe_params[:id]).ancestors
          { flows: (safe_params[:display_type] == 'full') ? Flow::Entity.represent(ancestors) : ancestors.map(&:id) }
        end

        desc 'Set Permissions to Flow of Case'
        params do
          requires :group_ids,       type: Array,  desc: 'Array of Group IDs'
          requires :permission_type, type: String, desc: 'Permission type to change (flow_can_execute_all_steps, flow_can_view_all_steps, flow_can_delete_own_cases, flow_can_delete_all_cases)'
        end
        put 'permissions' do
          authenticate!
          validate_permission!(:manage, Flow)
          permission_type          = safe_params[:permission_type]
          permission_types_array   = %w{flow_can_execute_all_steps flow_can_view_all_steps}
          permission_types_boolean = %w{flow_can_delete_own_cases flow_can_delete_all_cases}
          types = permission_types_array + permission_types_boolean
          error!(I18n.t(:permission_type_not_included), 400) unless types.include? permission_type

          safe_params[:group_ids].each do |group_id|
            group = Group.find(group_id)
            if permission_types_array.include? permission_type
              permissions = group.permissions[permission_type].present? ? eval(group.permissions[permission_type]) : []
              group.permissions[permission_type] = permissions.push(safe_params[:id])
            else
              group.permissions[permission_type] = true
            end
            group.permissions_will_change!
            group.save!
          end

          { message: I18n.t(:permissions_updated) }
        end

        desc 'Unset Permissions to Flow of Case'
        params do
          requires :group_ids,       type: Array,  desc: 'Array of Group IDs'
          requires :permission_type, type: String, desc: 'Permission type to change (flow_can_execute_all_steps, flow_can_view_all_steps, flow_can_delete_own_cases, flow_can_delete_all_cases)'
        end
        delete 'permissions' do
          authenticate!
          validate_permission!(:manage, Flow)
          permission_type          = safe_params[:permission_type]
          permission_types_array   = %w{flow_can_execute_all_steps flow_can_view_all_steps}
          permission_types_boolean = %w{flow_can_delete_own_cases flow_can_delete_all_cases}
          types = permission_types_array + permission_types_boolean
          error!(I18n.t(:permission_type_not_included), 400) unless types.include? permission_type

          safe_params[:group_ids].each do |group_id|
            group = Group.find(group_id)
            if permission_types_array.include? permission_type
              permissions = group.permissions[permission_type].present? ? eval(group.permissions[permission_type]) : []
              permissions.delete(safe_params[:id])
              group.permissions[permission_type] = permissions
            else
              group.permissions[permission_type] = false
            end
            group.permissions_will_change!
            group.save!
          end

          { message: I18n.t(:permissions_updated) }
        end
      end

      mount Flows::ResolutionStates::API
      mount Flows::Steps::API
    end
  end
end
