module ClusterizeItems
  class Cluster
    include ActiveModel::Model

    attr_accessor :items_ids, :category_id, :count, :center

    def position
      [center.y, center.x]
    end

    class Entity < Grape::Entity
      expose :items_ids
      expose :position
      expose :category_id
      expose :count
    end
  end
end
