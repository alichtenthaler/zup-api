module Search
  module Groups
    class API < Grape::API
      desc 'Search for groups'
      paginate per_page: 25
      params do
        optional :name, type: String, desc: 'The name of the group to search for'
        optional :like, type: Boolean, desc: 'Wether to use like search. Default is fuzzy.'
      end
      get :groups do
        authenticate!

        if params[:like]
          groups = Group.like_search(name: safe_params[:name])
        else
          groups = Group.fuzzy_search(name: safe_params[:name])
        end

        groups = paginate(groups)

        {
          groups: Group::Entity.represent(groups, only: return_fields)
        }
      end
    end
  end
end
