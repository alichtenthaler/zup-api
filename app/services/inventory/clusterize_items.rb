module Inventory
  class ClusterizeItems
    attr_reader :scope, :zoom

    def initialize(scope, zoom)
      @scope = scope
      @zoom = zoom
    end

    def results
      entities = nil

      with_large_work_mem do
        entities = Reports::Item.find_by_sql(
          build_sql
        )
      end

      data = {
        clusters: [],
        items: [],
        total: 0
      }
      items_ids = []

      entities.each do |entity|
        if entity.number_of_items > 1
          data[:clusters] << Inventory::Cluster.new(
            inventory_category_id: entity.inventory_category_id,
            geohash: entity.geohash,
            count: entity.number_of_items
          )

          data[:total] += entity.number_of_items
        else
          items_ids << entity.item_id
          data[:total] += 1
        end
      end

      data[:items] = Inventory::Item.where(id: items_ids)
                                    .includes(:user)
      data
    end

    private

    def build_sql
      <<-SQL
        SELECT min(scope.id) as item_id, inventory_category_id, geohash, COUNT(*) AS number_of_items
        FROM (#{changed_scope.to_sql}) as scope
        GROUP BY inventory_category_id, geohash;
      SQL
    end

    def zoom_to_chars
      chars = (zoom.to_f / 2).round

      if chars < 3
        chars = 3
      end

      chars
    end

    def changed_scope
      @scope.select(
        "*, ST_GeoHash(inventory_items.position, #{zoom_to_chars}) as geohash"
      ).order(id: :asc)
    end

    def with_large_work_mem
      Reports::Item.transaction do
        Reports::Item.connection.execute("SET work_mem='10MB';")
        yield
        Reports::Item.connection.execute("SET work_mem='1MB';")
      end
    end
  end
end
