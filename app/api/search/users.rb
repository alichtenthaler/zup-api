module Search::Users
  class API < Grape::API
    desc "Search for users"
    paginate per_page: 25
    params do
      optional :name, type: String, desc: "The name of the user to search for"
      optional :email, type: String, desc: "The email of the user to search for"
      optional :sort, type: String,
        desc: 'The field to sort the users. Values: `name`, `username`, `phone`, `email`, `created_at`, `updated_at`'
      optional :order, type: String,
        desc: 'The order, can be `desc` or `asc`'
    end
    get :users do
      authenticate!

      search_params = {
        name: safe_params[:name],
        email: safe_params[:email],
        sort: safe_params[:sort],
        order: safe_params[:order],
        like: true
      }

      users = ListUsers.new(search_params).fetch
      users = paginate(users)

      {
        users: User::Entity.represent(users, display_type: 'full')
      }
    end

    desc "Search for users on a group"
    paginate per_page: 25
    params do
      requires :group_id, type: Integer
      optional :name, type: String, desc: "The name of the user to search for"
      optional :email, type: String, desc: "The email of the user to search for"
      optional :sort, type: String,
        desc: 'The field to sort the users. Values: `name`, `username`, `phone`, `email`, `created_at`, `updated_at`'
      optional :order, type: String,
        desc: 'The order, can be `desc` or `asc`'
    end
    get "groups/:group_id/users" do
      authenticate!

      group = Group.find(safe_params[:group_id])
      search_params = {
        name: safe_params[:name],
        email: safe_params[:email],
        like: true,
        sort: safe_params[:sort],
        order: safe_params[:order],
        groups: [group]
      }

      users = ListUsers.new(search_params).fetch
      users = paginate(users)


      {
        users: User::Entity.represent(users, display_type: 'full')
      }
    end
  end
end
