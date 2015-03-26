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
  end
end
