module Inventory
  class Cluster
    include ActiveModel::Model

    attr_accessor :items_ids, :inventory_category_id, :count, :geohash

    def position
      GeoHash.decode(geohash)[0]
    end

    class Entity < Grape::Entity
      expose :items_ids
      expose :position
      expose :inventory_category_id, as: :category_id
      expose :count
    end
  end
end
