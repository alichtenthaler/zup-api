module Inventory
  class Cluster
    include ActiveModel::Model

    attr_accessor :items_ids, :inventory_category_id, :count, :geohash

    def category
      Inventory::Category.find_by(id: inventory_category_id)
    end

    def position
      GeoHash.decode(geohash)[0]
    end

    class Entity < Grape::Entity
      expose :items_ids
      expose :position
      expose :category, using: Inventory::Category::Entity
      expose :count
    end
  end
end
