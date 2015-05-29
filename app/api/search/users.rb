module Search::Users
  class API < Grape::API
    desc 'Search for users'
    paginate per_page: 25
    params do
      optional :name, type: String, desc: 'The name of the user to search for'
      optional :email, type: String, desc: 'The email of the user to search for'
      optional :sort, type: String,
        desc: 'The field to sort the users. Values: `name`, `username`, `phone`, `email`, `created_at`, `updated_at`'
      optional :order, type: String,
        desc: 'The order, can be `desc` or `asc`'
      optional :disabled, type: Boolean
      optional :user_document, type: String,
               desc: 'User document, only numbers'
    end
    get :users do
      authenticate!

      if safe_params[:groups]
        groups = safe_params[:groups].split(',').map do |group_id|
          Group.find(group_id)
        end
      end

      search_params = {
        name: safe_params[:name],
        email: safe_params[:email],
        document: safe_params[:document],
        sort: safe_params[:sort],
        order: safe_params[:order],
        groups: groups,
        disabled: safe_params[:disabled],
        like: true
      }

      users = ListUsers.new(search_params).fetch
      users = paginate(users.paginate(page: params[:page]))

      {
        users: User::Entity.represent(users, only: return_fields, display_type: 'full', show_groups: true)
      }
    end

    desc 'Search for users on a group'
    paginate per_page: 25
    params do
      requires :group_id, type: Integer
      optional :name, type: String, desc: 'The name of the user to search for'
      optional :email, type: String, desc: 'The email of the user to search for'
      optional :sort, type: String,
        desc: 'The field to sort the users. Values: `name`, `username`, `phone`, `email`, `created_at`, `updated_at`'
      optional :order, type: String,
        desc: 'The order, can be `desc` or `asc`'
      optional :user_document, type: String,
               desc: 'User document, only numbers'
    end
    get 'groups/:group_id/users' do
      authenticate!

      group = Group.find(safe_params[:group_id])
      search_params = {
        name: safe_params[:name],
        email: safe_params[:email],
        document: safe_params[:document],
        like: true,
        sort: safe_params[:sort],
        order: safe_params[:order],
        disabled: safe_params[:disabled],
        groups: [group]
      }

      users = ListUsers.new(search_params).fetch
      users = paginate(users.paginate(page: params[:page]))

      {
        users: User::Entity.represent(users, only: return_fields, display_type: 'full', show_groups: true)
      }
    end
  end
end
