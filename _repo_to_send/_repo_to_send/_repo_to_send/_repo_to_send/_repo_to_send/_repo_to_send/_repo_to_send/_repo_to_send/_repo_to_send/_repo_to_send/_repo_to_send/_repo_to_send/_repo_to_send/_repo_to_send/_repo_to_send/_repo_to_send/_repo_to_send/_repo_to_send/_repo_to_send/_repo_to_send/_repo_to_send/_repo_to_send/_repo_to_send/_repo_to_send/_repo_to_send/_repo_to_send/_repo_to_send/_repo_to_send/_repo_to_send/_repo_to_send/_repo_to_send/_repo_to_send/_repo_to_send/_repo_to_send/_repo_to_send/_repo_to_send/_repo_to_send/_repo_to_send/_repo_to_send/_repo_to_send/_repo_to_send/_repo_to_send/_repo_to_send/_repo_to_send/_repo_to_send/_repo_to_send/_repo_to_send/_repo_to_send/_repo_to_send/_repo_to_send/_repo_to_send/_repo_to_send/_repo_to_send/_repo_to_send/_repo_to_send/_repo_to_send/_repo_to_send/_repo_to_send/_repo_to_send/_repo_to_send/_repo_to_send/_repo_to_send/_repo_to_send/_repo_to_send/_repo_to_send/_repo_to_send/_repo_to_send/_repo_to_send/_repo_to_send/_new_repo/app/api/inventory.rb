module Inventory
  class API < Grape::API
    namespace :inventory do
      mount Inventory::Categories::API
      mount Inventory::Items::API
      mount Inventory::Statuses::API
      mount Inventory::Formulas::API
      mount Inventory::FieldOptions::API
      mount Inventory::ItemHistories::API
    end
  end
end
