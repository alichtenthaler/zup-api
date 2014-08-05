module Search::Inventory::Categories
  class API < Grape::API
    desc "Search for inventory categories"
    paginate per_page: 25
    params do
      optional :title, type: String, desc: "The name of the inventory category to search for"
    end
    get 'inventory/categories' do
      authenticate!

      categories = Inventory::Category.like_search(title: safe_params[:title])
      categories = paginate(categories)

      {
        categories: Inventory::Category::Entity.represent(categories)
      }
    end
  end
end
