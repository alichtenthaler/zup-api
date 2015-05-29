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
      logger Logger.new(
               GrapeLogging::MultiIO.new(
                 STDOUT, File.open("log/#{Application.config.env}.log", 'a')
               )
             )
      use GrapeLogging::Middleware::RequestLogger, logger: logger
    end

    helpers Garner::Mixins::Rack

    format :json
    default_format :json

    formatter :json, -> (object, _env) { Oj.dump(object) }

    rescue_from :all do |e|
      Raven.capture_exception(e)

      fail(e) if ENV['RAISE_ERRORS']
      API.logger.error e

      rack_response("{ \"error\": \"#{e.message}\", \"type\": \"unknown\" }", 400)
    end

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      res = { error: {}, type: 'params' }

      fail(e) if ENV['RAISE_ERRORS']

      e.errors.each do |field_name, error|
        res[:error].merge!(field_name[0] => error.map(&:to_s))
      end

      rack_response(res.to_json, 400)
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      Raven.capture_exception(e)

      fail(e) if ENV['RAISE_ERRORS']

      rack_response({ error: e.message, type: 'not_found' }.to_json, 404)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      Raven.capture_exception(e)

      fail(e) if ENV['RAISE_ERRORS']

      rack_response({ error: e.record.errors.messages.as_json, type: 'model_validation' }.to_json, 400)
    end

    rescue_from ActiveRecord::RecordNotUnique do |e|
      Raven.capture_exception(e)

      fail(e) if ENV['RAISE_ERRORS']

      rack_response({ error: I18n.t(:'errors.messages.unique'), type: 'model_validation' }.to_json, 400)
    end

    helpers do
      def current_user
        token = headers['X-App-Token'] || env['X-App-Token'] || params[:token]
        @current_user ||= User.authorize(token) if token
      end

      def authenticate!
        unless current_user
          error!('Unauthorized, Invalid or expired token', 401)
        end
      end

      def validate_permission!(action, model)
        if current_user
          permissions = user_permissions

          unless permissions.can?(action, model)
            table_name = if model.respond_to?(:table_name)
                           model.table_name
                         else
                           model.class.table_name
                         end

            action = I18n.t(action.to_sym)
            table  = I18n.t(table_name.to_sym)

            error!({ error: I18n.t(:permission_denied, action: action, table_name: table), type: 'invalid_permission' }, 403)
          end
        end
      end

      def user_permissions
        @user_permissions ||= UserAbility.for_user(current_user)
      end

      def safe_params
        ActionController::Parameters.new(params)
      end

      # This should go to a middleware
      def return_fields
        ReturnFieldsParams.new(params[:return_fields]).to_array
      end
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

    namespace :settings do
      desc 'Return the app settings'
      get do
        Settings.to_hash
      end
    end

    add_swagger_documentation
  end
end
