require 'grape-swagger'
require 'garner/mixins/rack'
require 'oj'
require 'will_paginate/array'
require 'rack/test'
require 'action_controller/metal/strong_parameters'

module ZUP
  class API < Grape::API
    use Appsignal::Rack::Listener
    use Appsignal::Grape::Middleware
    use Rack::ConditionalGet
    use Rack::ETag

    if Application.config.env.development?
      logger.formatter = GrapeLogging::Formatters::Default.new
      logger Application.logger
      use GrapeLogging::Middleware::RequestLogger, logger: logger
    end

    helpers Garner::Mixins::Rack

    # This is necessary because `grape-swagger`
    # gem adds this, thus causing CORS error
    # when trying to load externally the documentation
    # endpoint.
    after do
      header.delete('Access-Control-Allow-Origin')
      header.delete('Access-Control-Request-Method')
    end

    mount Users::API
    mount Groups::API
    mount Inventory::API
    mount Reports::API
    mount Search::API
    mount Flows::API
    mount Cases::API
    mount FeatureFlags::API
    mount Utils::API
    mount Auth::API
    mount BusinessReports::API

    namespace :settings do
      desc 'Return the app settings'
      get do
        Settings.to_hash
      end
    end

    add_swagger_documentation(hide_format: true)
  end
end
