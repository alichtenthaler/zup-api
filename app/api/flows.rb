module Flows
  class API < Base::API
    resources :flows do
      desc 'List of all flows'
      params do
        optional :initial,      type: Boolean, desc: 'Filter by Initial Flow'
        optional :display_type, type: String,  desc: 'Display type for Flow'
      end
      get do
        authenticate!
        validate_permission!(:view, Flow)
        { flows: Flow::Entity.represent(Flow.where(safe_params.permit(:initial)), only: return_fields, display_type: safe_params[:display_type]) }
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
        { message: I18n.t(:flow_created), flow: Flow::Entity.represent(flow, only: return_fields, display_type: 'full') }
      end

      resource ':id' do
        desc 'Show a flow'
        params do
          optional :display_type, type: String,  desc: 'Display type for Flow'
          optional :version,      type: Integer, desc: 'Version ID (last version by default)'
          optional :draft,        type: Boolean, desc: 'Draft or Live version (false by default)'
        end
        get do
          authenticate!
          validate_permission!(:view, Flow)

          flow = Flow.find(safe_params[:id]).the_version(safe_params[:draft], safe_params[:version])
          { flow: Flow::Entity.represent(flow, only: return_fields, display_type: safe_params[:display_type]) }
        end

        desc 'Delete a flow'
        delete do
          authenticate!
          validate_permission!(:delete, Flow)

          flow = Flow.find(safe_params[:id])
          flow.user = current_user
          flow.inactive!
          { message: I18n.t(:flow_deleted) }
        end

        desc 'Update a flow'
        params do
          requires :title,       type: String,  desc: 'Title of flow'
          optional :description, type: String,  desc: 'Description of flow'
          optional :initial,     type: Boolean, desc: 'If flow is initial'
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
          { flows: (safe_params[:display_type] == 'full') ? Flow::Entity.represent(ancestors, only: return_fields) : ancestors.map(&:id) }
        end

        desc 'Change the useful version of Flow'
        params { requires :new_version, type: Integer, desc: 'New Version ID to Default' }
        put 'version' do
          authenticate!
          validate_permission!(:manage, Flow)

          flow = Flow.find(safe_params[:id])
          error!(I18n.t(:version_isnt_valid), 400) if flow.versions.size.zero? || !flow.versions.pluck(:id).include?(safe_params[:new_version].to_i)
          flow.update! current_version: safe_params[:new_version].to_i

          { message: I18n.t(:flow_version_updated, version: safe_params[:new_version]) }
        end

        desc 'Set Permissions to Flow of Case'
        params do
          requires :group_ids,       type: Array,  desc: 'Array of Group IDs'
          requires :permission_type, type: String, desc: 'Permission type to change (flow_can_execute_all_steps, flow_can_view_all_steps, flow_can_delete_own_cases, flow_can_delete_all_cases)'
        end
        put 'permissions' do
          authenticate!
          validate_permission!(:manage, Flow)
          permission_type  = safe_params[:permission_type]
          permission_types = %w{flow_can_execute_all_steps flow_can_view_all_steps flow_can_delete_own_cases flow_can_delete_all_cases}
          error!(I18n.t(:permission_type_not_included), 400) unless permission_types.include? permission_type

          safe_params[:group_ids].each do |group_id|
            group       = Group.find(group_id)
            permissions = group.permission.send(permission_type)
            group.permission.send("#{permission_type}=", permissions + [safe_params[:id].to_i])
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
          permission_type  = safe_params[:permission_type]
          permission_types = %w{flow_can_execute_all_steps flow_can_view_all_steps flow_can_delete_own_cases flow_can_delete_all_cases}
          error!(I18n.t(:permission_type_not_included), 400) unless permission_types.include? permission_type

          safe_params[:group_ids].each do |group_id|
            group       = Group.find(group_id)
            permissions = group.permission.send(permission_type)
            group.permission.send("#{permission_type}=", permissions - [safe_params[:id].to_i])
            group.save!
          end

          { message: I18n.t(:permissions_updated) }
        end

        desc 'Publish the flow'
        post 'publish' do
          authenticate!
          validate_permission!(:manage, Flow)

          Flow.find(safe_params[:id]).publish(current_user)

          { message: I18n.t(:flow_published) }
        end
      end

      mount Flows::ResolutionStates::API
      mount Flows::Steps::API
    end
  end
end
