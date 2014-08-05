class Reports::GetStats
  attr_accessor :categories, :begin_date, :end_date

  def initialize(category_id, filters = {})
    if category_id.is_a? Array
      @categories = category_id.map do |id|
        Reports::Category.find(id)
      end
    else
      @categories = [Reports::Category.find(category_id)]
    end

    @begin_date = filters[:begin_date]
    @end_date = filters[:end_date]
  end

  def fetch
    stats = []

    categories.each do |category|
      category_stats = {}
      category_stats.merge!(
        category_id: category.id,
        name: category.title
      )

      statuses_stats = []
      category.statuses.each do |status|
        reports_items = status.reports_items.where(reports_category_id: category.id)

        if begin_date || end_date
          if begin_date && end_date
            reports_items = reports_items.where(created_at: begin_date..end_date)
          elsif begin_date
            reports_items = reports_items.where("created_at >= ?", begin_date)
          elsif end_date
            reports_items = reports_items.where("created_at <= ?", end_date)
          end
        end

        statuses_stats << {
          status_id: status.id,
          title: status.title,
          count: reports_items.count,
          color: status.color
        }
      end

      category_stats[:statuses] = statuses_stats
      stats << category_stats
    end

    stats
  end
end
