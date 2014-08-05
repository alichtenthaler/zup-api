module Search
  class API < Grape::API
    namespace :search do
      mount Search::Groups::API
      mount Search::Users::API

      # Reports
      mount Search::Reports::Items::API

      # Inventory
      mount Search::Inventory::Items::API
      mount Search::Inventory::Categories::API
    end
  end
end
