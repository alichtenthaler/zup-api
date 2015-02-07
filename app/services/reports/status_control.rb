module Reports
  class StatusControl
    attr_reader :item

    def initialize(item)
      @item = item
    end

    def self.reports_with_possible_overdue
      join_sql = <<-SQL
        INNER JOIN "#{Reports::StatusCategory.table_name}"
        ON "#{Reports::StatusCategory.table_name}"."reports_category_id" = "reports_items"."reports_category_id"
        AND "#{Reports::StatusCategory.table_name}"."reports_status_id" = "reports_items"."reports_status_id"
      SQL

      Reports::Item.joins(join_sql)
                   .merge(Reports::StatusCategory.in_progress)
                   .merge(Reports::StatusCategory.active)
    end

    def overdue?
      category = item.category
      relation = category.status_categories.with_status(item.status)

      # Status can't be initial or final
      return false if relation.final? || relation.initial?

      # Initial status
      initial_status = item.status_history.first

      resolution_time = category.resolution_time

      if resolution_time
        (initial_status.created_at + resolution_time.seconds) <= Time.now
      else
        false
      end
    end
  end
end
