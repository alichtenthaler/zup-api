module Flows
  module ResolutionStates
    class API < Grape::API
      resources ':flow_id/resolution_states' do
        desc 'Create a Resolution State'
        params do
          requires :title,   type: String,  desc: 'Title of resolution state'
          optional :default, type: Boolean, desc: 'If is default state (only one)'
        end
        post do
          authenticate!
          validate_permission!(:create, ResolutionState)

          flow        = Flow.find(safe_params[:flow_id])
          parameters  = safe_params.permit(:title, :default).merge(user: current_user)

          old_default = flow.resolution_states.find_by_default(true)
          old_default.update!(default: false, user: current_user) if safe_params[:default] && old_default.present?
          resolution = flow.resolution_states.create!(parameters)

          { message: I18n.t(:resolution_state_created), resolution_state: ResolutionState::Entity.represent(resolution, only: return_fields) }
        end

        desc 'Update a Resolution State'
        params do
          requires :title,   type: String,  desc: 'Title of resolution state'
          optional :default, type: Boolean, desc: 'If is default state (only one)'
        end
        put ':id' do
          authenticate!
          validate_permission!(:update, ResolutionState)

          resolution  = Flow.find(safe_params[:flow_id]).resolution_states.find(safe_params[:id])
          old_default = Flow.find(safe_params[:flow_id]).resolution_states.find_by_default(true)
          old_default.update!(default: false, user: current_user) if safe_params[:default] && old_default.present?
          parameters = safe_params.permit(:title, :default).merge(user: current_user)
          { message: I18n.t(:resolution_state_updated) } if resolution.update!(parameters)
        end

        desc 'Delete a Resolution State'
        delete ':id' do
          authenticate!
          validate_permission!(:delete, ResolutionState)

          resolution = Flow.find(safe_params[:flow_id]).resolution_states.find(safe_params[:id])
          resolution.user = current_user
          resolution.inactive!
          { message: I18n.t(:resolution_state_deleted) }
        end
      end
    end
  end
end
