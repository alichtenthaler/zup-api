require 'grape-swagger'
require 'garner/mixins/rack'
require 'oj'
require 'will_paginate/array'
require 'return_fields_params'

module ZUP
  class API < Grape::API
    helpers Garner::Mixins::Rack
    use Rack::ConditionalGet
    use Rack::ETag

    format :json
    default_format :json

    rescue_from :all do |e|
      Raven.capture_exception(e)

      if ENV['RAISE_ERRORS']
        fail e
      end

      rack_response("{ \"error\": \"#{e.message}\" }", 400)
    end

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      res = { error: {} }

      if ENV['RAISE_ERRORS']
        fail e
      end

      e.errors.each do |field_name, error|
        res[:error].merge!(field_name[0] => error.map(&:to_s))
      end

      rack_response(res.to_json, 400)
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      Raven.capture_exception(e)

      if ENV['RAISE_ERRORS']
        fail e
      end

      rack_response({ error: e.message }.to_json, 404)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      Raven.capture_exception(e)

      if ENV['RAISE_ERRORS']
        fail e
      end

      rack_response({ error: e.record.errors.messages.as_json }.to_json, 400)
    end

    helpers do
      def current_user
        token = headers['X-App-Token'] || params[:token]
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
            error!(I18n.t(:permission_denied, action: action, table_name: table), 403)
          end
        end
      end

      def user_permissions
        @user_permissions ||= UserAbility.new(current_user)
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

    namespace :settings do
      desc 'Return the app settings'
      get do
        Settings.to_hash
      end
    end

    add_swagger_documentation
  end
end
