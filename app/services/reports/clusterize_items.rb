module Reports
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
        reports: [],
        total: 0
      }

      entities.each do |entity|
        if entity.number_of_items > 1
          data[:clusters] << Reports::Cluster.new(
            reports_category_id: entity.reports_category_id,
            geohash: entity.geohash,
            count: entity.number_of_items
          )

          data[:total] += entity.number_of_items
        else
          data[:reports] << Reports::Item.find(entity.item_id)
          data[:total] += 1
        end
      end

      data
    end

    private

    def build_sql
      <<-SQL
        SELECT min(scope.id) as item_id, reports_category_id, geohash, COUNT(*) AS number_of_items
        FROM (#{changed_scope.to_sql}) as scope
        GROUP BY reports_category_id, geohash;
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
      @scope.distinct.select(
        "*, ST_GeoHash(reports_items.position, #{zoom_to_chars}) as geohash"
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
