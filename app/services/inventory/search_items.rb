class Inventory::SearchItems
  attr_reader :fields, :categories, :position_params,
              :limit, :sort, :order, :address, :statuses,
              :created_at, :updated_at, :title, :users,
              :query, :user, :clusterize, :zoom, :page, :per_page,
              :paginator

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
    @page = opts[:page]
    @per_page = opts[:per_page] || 25
    @paginator = opts[:paginator]
  end

  def search
    scope = Inventory::Item.includes(:category, :user)
    permissions = UserAbility.for_user(user)

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

      if user
        permission_statement = ''
        Inventory::Category.where(id: categories_ids).each_with_index do |category, i|
          if i > 0
            permission_statement += ' OR '
          end

          if permissions.can?(:view_all_items, category)
            permission_statement = "(inventory_category_id = #{category.id})"
          else
            permission_statement = "(inventory_category_id = #{category.id} AND user_id = #{user.id})"
          end
        end
      else
        permission_statement = { inventory_category_id: categories_ids }
      end

      scope = scope.where(permission_statement)
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

      statement = ''
      position_hash.each do |_index, p|
        latlon = "POINT(#{p[:longitude].to_f} #{p[:latitude].to_f})"

        unless statement.blank?
          statement += ' OR '
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
      if created_at[:begin] && created_at[:end]
        begin_date = DateTime.parse(created_at[:begin])
        end_date = DateTime.parse(created_at[:end])

        scope = scope.where(inventory_items: { created_at: begin_date..end_date })
      elsif created_at[:begin]
        begin_date = DateTime.parse(created_at[:begin])
        scope = scope.where('inventory_items.created_at >= ?', begin_date)
      elsif created_at[:end]
        end_date = DateTime.parse(created_at[:end])
        scope = scope.where('inventory_items.created_at <= ?', end_date)
      end
    end

    if updated_at && (updated_at[:begin] || updated_at[:end])
      if updated_at[:begin] && updated_at[:end]
        begin_date = DateTime.parse(updated_at[:begin])
        end_date = DateTime.parse(updated_at[:end])

        scope = scope.where(updated_at: begin_date..end_date)
      elsif updated_at[:begin]
        begin_date = DateTime.parse(updated_at[:begin])
        scope = scope.where('updated_at >= ?', begin_date)
      elsif updated_at[:end]
        end_date = DateTime.parse(updated_at[:end])
        scope = scope.where('updated_at <= ?', end_date)
      end
    end

    if limit
      scope = scope.limit(limit)
    end

    if fields.any?
      scope = Inventory::SearchItemsByFields.new(scope, fields).scope_with_filters
    end

    sort = self.sort
    if sort && !clusterize &&
      %w(title inventory_category_id created_at updated_at id user_name).include?(sort) &&
      %w(desc asc).include?(order.downcase)

      if sort == 'user_name'
        sort = 'users.name'
      elsif sort == 'id'
        sort = 'inventory_items.id'
      end

      if scope.is_a?(Array)
      end

      if sort == 'title'
        scope = scope.order("title #{order}, sequence #{order}")
      else
        scope = scope.order("#{sort} #{order.downcase}")
      end

      if paginator.present?
        scope = paginator.call(scope)
      end
    elsif position_params.blank?
      scope = scope.paginate(page: page, per_page: per_page)
    end

    if position_params && clusterize
      ClusterizeItems::Inventory.new(scope, zoom).results
    else
      scope
    end
  end
end
