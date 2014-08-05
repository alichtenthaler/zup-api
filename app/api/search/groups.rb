module Search::Groups
  class API < Grape::API
    desc "Search for groups"
    paginate per_page: 25
    params do
      optional :name, type: String, desc: "The name of the group to search for"
    end
    get :groups do
      authenticate!

      groups = Group.fuzzy_search(name: safe_params[:name])
      groups = paginate(groups)

      {
        groups: Group::Entity.represent(groups)
      }
    end
  end
end
