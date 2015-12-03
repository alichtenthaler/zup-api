class Reports::SearchItems
  attr_reader :category, :user,
              :inventory_item, :position_params,
              :statuses, :begin_date,
              :end_date, :limit,
              :group_by_inventory_item, :sort,
              :order, :paginator, :page,
              :per_page, :address, :query,
              :signed_user, :overdue, :clusterize, :zoom,
              :assigned_to_my_group, :assigned_to_me, :reporter,
              :user_document, :flagged_offensive, :days_since_last_notification,
              :days_for_last_notification_deadline, :minimum_notification_number,
              :days_for_overdue_notification, :with_notifications,
              :perimeter

  def initialize(user, opts = {})
    @signed_user     = user
    @position_params = opts.delete(:position)

    opts.each do |key, value|
      instance_variable_set("@#{key}", value)
    end

    @category   ||= []
    @clusterize ||= false
    @sort       ||= 'created_at'
    @order      ||= 'desc'
    @page       ||= 1
    @per_page   ||= 25
  end

  def search
    scope = Reports::Item.includes(
      :images, :comments, :category, :inventory_item, :assigned_group,
      :assigned_user, user: :groups, reporter: :groups, offensive_flags: :user,
      notifications: :notification_type
    )

    permissions = UserAbility.for_user(signed_user)

    if inventory_item
      scope = scope.where(inventory_item_id: inventory_item.id)
    end

    if group_by_inventory_item
      # Select only unique inventory_item_id
      scope = scope.select(
        <<-SQL
          DISTINCT ON (COALESCE(reports_items.inventory_item_id, reports_items.id)) reports_items.*
        SQL
      )
    end

    if query
      scope = scope.joins(:user).like_search(
        'users.name' => query,
        address: query,
        protocol: query,
        district: query,
        postal_code: query.gsub(/[^0-9]*/, '')
      )
    end

    if user_document
      scope = scope.joins(:user).like_search(
        'users.document' => user_document
      )
    end

    if user
      if user.is_a?(Array)
        users_ids = user.map { |u| u.id }
      elsif user.is_a?(User)
        users_ids = user.id
      end

      scope = scope.where(user_id: users_ids)
    end

    if reporter
      if reporter.is_a?(Array)
        reporters_ids = reporter.map { |r| r.id }
      elsif reporter.is_a?(User)
        reporters_ids = reporter.id
      end

      scope = scope.where(reporter_id: reporters_ids)
    end

    if category
      if category.is_a?(Array)
        categories_ids = category.map { |c| c.id }
      elsif category.is_a?(Reports::Category)
        categories_ids = [category.id]
      end
    end

    if perimeter
      if perimeter.is_a?(Array)
        perimeters_ids = perimeter.map { |p| p.id }
      elsif perimeter.is_a?(Reports::Perimeter)
        perimeters_ids = [perimeter.id]
      end

      scope = scope.where(reports_perimeter_id: perimeters_ids)
    end

    if !permissions.can?(:manage, Reports::Category)
      categories_user_can_see = permissions.reports_categories_visible_for_items

      if categories_ids.any?
        categories_ids = categories_user_can_see & categories_ids
      else
        categories_ids = categories_user_can_see
      end

      scope = scope.where(reports_category_id: categories_ids)
    elsif categories_ids.any?
      scope = scope.where(reports_category_id: categories_ids)
    end

    if position_params
      scope = Reports::SearchItemsByGeolocation.new(
        scope, position_params, address
      ).scope_with_filters
    elsif address
      scope = scope.like_search(
        address: address,
        district: address,
        postal_code: address.gsub(/[^0-9]*/, '')
      )
    end

    if limit
      scope = scope.limit(limit)
    end

    if begin_date || end_date
      @begin_date = begin_date.try(:to_time).try(:beginning_of_day)
      @end_date   = end_date.try(:to_time).try(:end_of_day)

      if begin_date && end_date
        scope = scope.where('reports_items.created_at' => begin_date..end_date)
      elsif begin_date
        scope = scope.where('reports_items.created_at >= ?', begin_date)
      elsif end_date
        scope = scope.where('reports_items.created_at <= ?', end_date)
      end
    end

    if overdue
      scope = scope.where(overdue: overdue)
    end

    if statuses
      scope = scope.where('reports_status_id IN (?)', statuses.map(&:id))
    end

    if assigned_to_my_group
      scope = scope.where(
        reports_items: {
          assigned_group_id: signed_user.groups.pluck(:id)
        }
      )
    end

    if assigned_to_me
      scope = scope.where(
        reports_items: {
          assigned_user_id: signed_user.id
        }
      )
    end

    if flagged_offensive
      scope = scope.joins(:offensive_flags)
    end

    if permissions.cannot?(:manage, Reports::Category)
      if permissions.reports_categories_with_editable_items.any?
        query = <<-SQL
          offensive = FALSE OR (offensive = TRUE AND reports_items.reports_category_id IN (?))
        SQL

        scope = scope.where(
          query, permissions.reports_categories_with_editable_items
        )
      else
        scope = scope.where(offensive: false)
      end
    end

    if with_notifications
      scope = scope.joins(:notifications)
    end

    if days_since_last_notification && days_since_last_notification[:begin] && days_since_last_notification[:end]
      begin_date = days_since_last_notification[:begin]
      end_date = days_since_last_notification[:end]

      scope = scope.joins(:notifications)
                   .having(
                     "DATE_PART('day', current_date::timestamp - MAX(reports_notifications.created_at::timestamp)) BETWEEN ? and ?",
                     begin_date, end_date
                   ).group('reports_items.id')
    end

    if days_for_last_notification_deadline && days_for_last_notification_deadline[:begin] && days_for_last_notification_deadline[:end]
      begin_date = days_for_last_notification_deadline[:begin]
      end_date = days_for_last_notification_deadline[:end]

      scope = scope.joins(:notifications)
                   .having(
                     "DATE_PART('day', MAX(reports_notifications.overdue_at)::timestamp - current_date::timestamp) BETWEEN ? and ?",
                     begin_date, end_date
                   ).group('reports_items.id')
    end

    if minimum_notification_number
      scope = scope.joins(:notifications)
                   .having(
                     'COUNT(reports_notifications.id) >= ?',
                     minimum_notification_number
                   ).group('reports_items.id')
    end

    if days_for_overdue_notification && days_for_overdue_notification[:begin] && days_for_overdue_notification[:end]
      begin_date = days_for_overdue_notification[:begin]
      end_date = days_for_overdue_notification[:end]

      scope = scope.joins(:notifications)
                   .having(
                     "DATE_PART('day', current_date::timestamp - MAX(reports_notifications.overdue_at)::timestamp) BETWEEN ? and ?",
                     begin_date, end_date
                   ).group('reports_items.id')
    end

    if sort && !clusterize &&
        %w(created_at updated_at id reports_status_id user_name priority).include?(sort) &&
        %w(desc asc).include?(order.downcase)

      if sort == 'priority'
        @sort = 'reports_categories.priority'
      elsif sort == 'user_name'
        @sort = 'users.name'
      elsif %w(created_at id).include?(sort)
        @sort = "reports_items.#{sort}"
      end

      scope = Reports::Item.from("(#{scope.to_sql}) reports_items")
                   .joins(:user, :category)
                   .preload(
                     :images, :comments, :category, :inventory_item, user: :groups
                   ).order("#{sort} #{order.downcase}")

      if paginator.present?
        scope = paginator.call(scope)
      end
    elsif position_params.blank?
      scope = scope.paginate(page: page, per_page: per_page)
    end

    if position_params && clusterize
      ClusterizeItems::Reports.new(scope, zoom).results
    else
      scope
    end
  end
end
