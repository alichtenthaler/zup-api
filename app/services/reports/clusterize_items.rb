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
      items_ids = []

      entities.each do |entity|
        if entity.number_of_items > 1
          data[:clusters] << Reports::Cluster.new(
            reports_category_id: entity.reports_category_id,
            geohash: entity.geohash,
            count: entity.number_of_items
          )

          data[:total] += entity.number_of_items
        else
          items_ids << entity.item_id
          data[:total] += 1
        end
      end

      data[:items] = Reports::Item.where(id: items_ids)
                                  .includes(:user)
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
      @zoom_map ||= {
          '0' => 2,
          '1' => 2,
          '2' => 2,
          '3' => 2,
          '4' => 2,
          '5' => 2,
          '6' => 3,
          '7' => 3,
          '8' => 4,
          '9' => 5,
          '10' => 5,
          '11' => 5,
          '12' => 5,
          '13' => 6,
          '14' => 6,
          '15' => 6,
          '16' => 7,
          '17' => 7,
          '18' => 8,
          '19' => 9,
          '20' => 10
      }

      @zoom_map[zoom.to_s] || 5
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
