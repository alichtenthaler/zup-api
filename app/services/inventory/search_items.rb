class Inventory::SearchItems
  attr_reader :fields, :categories, :position_params,
              :limit, :sort, :order, :address, :statuses,
              :created_at, :updated_at, :title, :users,
              :query, :user, :clusterize, :zoom

  def initialize(user, opts = {})
    @position_params = opts[:position]
    @categories = opts[:categories] || []
    @users = opts[:users] || []
    @statuses = opts[:statuses] || []
    @address = opts[:address]
    @title = opts[:title]
    @limit = opts[:limit]
    @created_at = opts[:created_at]
    @updated_at = opts[:updated_at]
    @sort = opts[:sort]
    @order = opts[:order] || 'desc'
    @fields = opts[:fields] || {}
    @query = opts[:query]
    @user = user
    @clusterize = opts[:clusterize]
    @zoom = opts[:zoom]
  end

  def search
    scope = Inventory::Item.includes(:data)
    permissions = UserAbility.new(user)

    sort = self.sort
    if sort &&
        sort.in?('title', 'inventory_category_id', 'created_at', 'updated_at', 'id') &&
        order.downcase.in?('desc', 'asc')

      if sort == 'title'
        scope = scope.order("title #{order}, sequence #{order}")
      else
        scope = scope.order("#{sort} #{order.to_sym}")
      end

    end

    if query
      scope = scope.like_search(
        id: query,
        address: query,
        title: query
      )
    end

    if categories.any?
      categories_ids = categories.map(&:id)
    end

    if !permissions.can?(:manage, Inventory::Category)
      categories_user_can_see = permissions.inventory_categories_visible

      if categories_ids && categories_ids.any?
        categories_ids = categories_user_can_see & categories_ids
      else
        categories_ids = categories_user_can_see
      end

      scope = scope.where(inventory_category_id: categories_ids)
    elsif categories_ids && categories_ids.any?
      scope = scope.where(inventory_category_id: categories_ids)
    end

    if statuses.any?
      scope = scope.where(inventory_status_id: statuses.map(&:id))
    end

    if users.any?
      scope = scope.where(user_id: users.map(&:id))
    end

    if title.present?
      scope = scope.like_search(title: title)
    end

    if position_params
      # If it is a simple hash, transform to complex one
      position_hash = if position_params.key?(:latitude)
                        { 0 => position_params }
                      else
                        position_params
                      end

      statement = ""
      position_hash.each do |index, p|
        latlon = "POINT(#{p[:longitude].to_f} #{p[:latitude].to_f})"

        unless statement.blank?
          statement += " OR "
        end

        statement += <<-SQL
          ST_DWithin(
            ST_GeomFromText('#{latlon}', 4326)::geography,
            position, #{p[:distance].to_i}
          )
        SQL
      end

      if address
        statement += <<-SQL
          OR inventory_items.address ILIKE ?
        SQL

        scope = scope.where(statement, "%#{address}%")
      else
        scope = scope.where(statement)
      end
    else
      if address
        scope = scope.like_search(address: address)
      end
    end

    if created_at && (created_at[:begin] || created_at[:end])
      begin_date = DateTime.parse(created_at[:begin])
      end_date = DateTime.parse(created_at[:end])

      if begin_date && end_date
        scope = scope.where(inventory_items: { created_at: begin_date..end_date })
      elsif begin_date
        scope = scope.where("inventory_items.created_at >= ?", begin_date)
      elsif end_date
        scope = scope.where("inventory_items.created_at <= ?", end_date)
      end
    end

    if updated_at && (updated_at[:begin] || updated_at[:end])
      begin_date = updated_at[:begin]
      end_date = updated_at[:end]

      if begin_date && end_date
        scope = scope.where(updated_at: begin_date..end_date)
      elsif begin_date
        scope = scope.where("updated_at >= ?", begin_date)
      elsif end_date
        scope = scope.where("updated_at <= ?", end_date)
      end
    end

    if limit
      scope = scope.limit(limit)
    end

    if fields.any?
      scope = Inventory::SearchItemsByFields.new(scope, fields).scope_with_filters
    end

    if position_params && clusterize
      Inventory::ClusterizeItems.new(scope, zoom).results
    else
      scope
    end
  end
end
