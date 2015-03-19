module Reports
  class Cluster
    include ActiveModel::Model

    attr_accessor :reports_ids, :reports_category_id, :count, :geohash

    def position
      GeoHash.decode(geohash)[0]
    end

    class Entity < Grape::Entity
      expose :reports_ids
      expose :position
      expose :reports_category_id, as: :category_id
      expose :count
    end
  end
end
