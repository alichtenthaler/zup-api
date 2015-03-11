module Reports
  class Cluster
    include ActiveModel::Model

    attr_accessor :reports_ids, :reports_category_id, :count, :geohash

    def category
      Reports::Category.find_by(id: reports_category_id)
    end

    def position
      GeoHash.decode(geohash)[0]
    end

    class Entity < Grape::Entity
      expose :reports_ids
      expose :position
      expose :category, using: Reports::Category::Entity
      expose :count
    end
  end
end
