module Base
  class API < Grape::API
    def self.inherited(subclass)
      super

      subclass.instance_eval do
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

        rescue_from Reports::ValidateVersion::VersionMismatch do |e|
          Raven.capture_exception(e)

          fail(e) if ENV['RAISE_ERRORS']

          rack_response({ error: I18n.t(:'errors.messages.version_mismatch'), type: 'version_mismatch' }.to_json, 400)
        end

        before do
          unallowed_bs_endpoints = %w(/users/unsubscribe/:token /reset_password /recover_password)
          # If a token comes with the request, let's validate it
          # before doing anything, if it's invalid let's return an error
          unless unallowed_bs_endpoints.include?(route.route_path)
            validates_app_token! if app_token
          end
        end

        format :json
        default_format :json

        formatter :json, -> (object, _env) { Oj.dump(object) }

        helpers do
          def app_token
            # TODO: Remove this BS
            return false if (headers['X-App-Token'].blank? || headers['X-App-Token'] == 'null') && env['X-App-Token'].blank? && params[:token].blank?
            @app_token ||= headers['X-App-Token'] || env['X-App-Token'] || params[:token]
          end

          def validates_app_token!
            @current_user ||= User.authorize(app_token)
            authenticate!
          end

          def current_user
            @current_user
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
      end
    end # --initialize
  end
end
