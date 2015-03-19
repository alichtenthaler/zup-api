module Users
  class API < Grape::API
    desc "Authenticate user and return a valid access token"
    params do
      requires :email, type: String, desc: "User's email address"
      requires :password, type: String, desc: "User's password"
      optional :device_token, type: String, desc: "The device token if registration is from mobile"
      optional :device_type, type: String, desc: "Could be ios or android"
    end
    post :authenticate do
      user = User.authenticate(params[:email], params[:password])

      if params[:device_token] || params[:device_type]
        user_params = safe_params.permit(:device_token, :device_type)
        user.update(user_params)
      end

      if user
        return {
          user: User::Entity.represent(
                  user,
                  display_type: 'full',
                  display_groups: true
                ),
          token: user.last_access_key
        }
      else
        status(401)
        { error: 'E-mail e senha incorretos ou não existem no sistema' }
      end
    end

    desc "Logout: invalidate access token"
    params do
      requires :token, type: String, desc: "The access token"
    end
    delete :sign_out do
      authenticate!

      if safe_params[:token].present?
        access_key = current_user.access_keys.find_by!(key: safe_params[:token])
        access_key.expire!
      else
        current_user.access_keys.active.each(&:expire!)
      end

      { message: "Token invalidado com sucesso!" }
    end

    # Password recovery
    desc "Recover user's password"
    params do
      requires :email, type: String, desc: "The user's email address"
    end
    put :recover_password do
      User.request_password_recovery(params[:email])

      { message: "E-mail de recuperação de senha enviado com sucesso!" }
    end

    desc "Resets user's password"
    params do
      requires :token, type: String, desc: "The password reset token"
      requires :new_password, type: String, desc: "The new password for the account"
    end
    put :reset_password do
      if User.reset_password(params[:token], params[:new_password])
        { message: "Senha alterada com sucesso!" }
      else
        { message: "Token de acesso inválido ou expirado." }
      end
    end

    desc "Shows authenticated info"
    get :me do
      authenticate!

      current_user.groups.includes(:permission)

      { user: User::Entity.represent(current_user,
                                     only: return_fields,
                                     display_type: 'full'
                                    ) }
    end

    desc "Destroy current user account"
    delete :me do
      authenticate!
      current_user.disable!

      { message: "Conta deletada com sucesso." }
    end

    # Users CRUD
    resources :users do
      desc "List all registered users"
      paginate per_page: 25
      params do
        optional :name, type: String
        optional :email, type: String
        optional :groups, type: Array
      end
      get do
        authenticate!

        search_params = params

        name = search_params.delete(:name)
        email = search_params.delete(:email)
        groups_ids = search_params.delete(:groups)

        search_query = {}
        users = User.enabled

        if name
          search_query = search_query.merge(name: name)
        end

        if email
          search_query = search_query.merge(email: email)
        end

        if groups_ids
          users = users.includes(:groups)
                       .references(:groups)
                       .where("groups.id IN (?)", groups_ids)
        end

        unless search_query.empty?
          users = users.fuzzy_search(search_query)
        end

        {
          users: User::Entity.represent(
            paginate(users), display_type: 'full'
          )
        }
      end

      desc "Create an user"
      params do
        requires :email, type: String, desc: "User's email address used for sign in"
        requires :password, type: String, desc: "User's password"
        requires :password_confirmation, type: String, desc: "User's password confirmation"

        requires :name, type: String, desc: "User's name"
        requires :phone, type: String, desc: "Phone, only numbers"
        requires :document, type: String, desc: "User's document (CPF), only numbers"
        requires :address, type: String, desc: "User's address (with the number)"
        optional :address_additional, type: String, desc: "Address complement"
        requires :postal_code, type: String, desc: "CEP"
        requires :district, type: String, desc: "User's neighborhood"
        optional :groups_ids, type: Array, desc: "User groups"

        optional :facebook_user_id, type: Integer, desc: "User's id on facebook"
        optional :twitter_user_id, type: Integer, desc: "User's id on twitter"
        optional :google_plus_user_id, type: Integer, desc: "User's id on G+"

        optional :device_token, type: String, desc: "The device token if registration is from mobile"
        optional :device_type, type: String, desc: "Could be `ios` or `android`"

        optional :email_notifications, type: Boolean, desc: "If the user wants email notification or not"
      end
      post do
        user = User.new(
          safe_params.permit(
            :password, :password_confirmation,
            :name, :email, :phone, :document, :address,
            :address_additional, :postal_code, :district,
            :facebook_user_id, :twitter_user_id,
            :google_plus_user_id, :groups_ids,
            :device_token, :device_type, :email_notifications
          )
        )

        if params[:groups_ids].present?
          validate_permission!(:manage, User)
          user.groups = params[:groups_ids].map do |id|
            Group.find(id)
          end
        else
          guest_group = Group.guest
          user.groups << guest_group if guest_group
        end

        user.save!

        {
          message: "Usuário criado com sucesso",
          user: User::Entity.represent(user, display_type: 'full')
        }
      end

      desc "Shows user info"
      get ':id' do
        user = User.find(safe_params[:id])
        { user: User::Entity.represent(user, display_type: 'full', display_groups: true) }
      end

      desc "Update user's info"
      params do
        optional :current_password, type: String, desc: "Current user's password"
        optional :password, type: String, desc: "User's password"
        optional :password_confirmation, type: String, desc: "User's password confirmation"

        optional :name, type: String, desc: "User's name"
        optional :email, type: String, desc: "User's email address"
        optional :phone, type: String, desc: "Phone, only numbers"
        optional :document, type: String, desc: "User's document (CPF), only numbers"
        optional :address, type: String, desc: "User's address (with the number)"
        optional :address_additional, type: String, desc: "Address complement"
        optional :postal_code, type: String, desc: "CEP"
        optional :district, type: String, desc: "User's neighborhood"

        optional :device_token, type: String, desc: "The device token if registration is from mobile"
        optional :device_type, type: String, desc: "Could be ios or android"

        optional :email_notifications, type: Boolean, desc: "If the user wants email notification or not"
      end
      put ':id' do
        authenticate!
        user = User.find(safe_params[:id])
        validate_permission!(:edit, user)

        user_params = safe_params.permit(
          :email, :current_password, :password,
          :password_confirmation, :name, :phone, :document, :address,
          :address_additional, :postal_code, :district,
          :device_token, :device_type, :email_notifications
        )

        user.update!(user_params.merge(user_changing_password: current_user))
        { message: "Conta alterada com sucesso." }
      end

      desc "Destroy user account"
      delete ':id' do
        authenticate!
        user = User.find(safe_params[:id])
        validate_permission!(:delete, user)

        user.disable!

        { message: "Conta deletada com sucesso." }
      end

      desc "Unsubscribe user from emails"
      params do
        requires :token, type: String, desc: ""
      end
      get 'unsubscribe/:token' do
        result = User.unsubscribe(params[:token])

        if result
          { message: "Você não receberá mais atualizações no seu e-mail!" }
        else
          { message: "Usuário não encontrado" }
        end
      end
    end
  end
end
