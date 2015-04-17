module Utils
  class API < Grape::API
    desc 'Validates if lat and lon is allowed for the city'
    params do
      requires :latitude, type: Float
      requires :longitude, type: Float
    end
    get '/utils/city-boundary/validate' do
      latitude, longitude = params[:latitude], params[:longitude]

      if CityShape.validation_enabled?
        { inside_boundaries: CityShape.contains?(latitude, longitude) }
      else
        { message: 'Validação para limite municipal não está ativo' }
      end
    end

    desc 'Return all available objects for permissions'
    get '/utils/available_objects' do
      authenticate!

      ability = UserAbility.new(current_user)

      unless ability.can?(:manage, Group) || current_user.permissions.group_edit.any?
        error!(I18n.t(:permission_denied, action: :manage, table_name: :groups), 403)
      end

      groups = Group.includes(:permission).all
      flows = Flow.all
      flow_steps = Step.all
      inventory_categories = Inventory::Category.all
      reports_categories = Reports::Category.includes(:statuses).all

      {
        groups: Group::Entity.represent(groups, only: [:id, :name]),
        flows: Flow::Entity.represent(flows, only: [:id, :title]),
        flow_steps: Step::Entity.represent(flow_steps, only: [:id, :title]),
        inventory_categories: Inventory::Category::Entity.represent(inventory_categories, only: [:id, :title]),
        reports_categories: Reports::Category::Entity.represent(reports_categories, only: [:id, :title])
      }
    end
  end
end
