class Inventory::SearchItems
  attr_reader :fields, :categories, :position_params,
              :limit, :sort, :order, :address, :statuses,
              :created_at, :updated_at, :title, :users,
              :query, :user

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
      begin_date = created_at[:begin]
      end_date = created_at[:end]

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
      scope = scope.where(build_fields_statement)
    end

    scope
  end

  private
  def build_fields_statement
    statement = ""

    fields.each do |field_id, filters|
      # Filters could be a hash like this:
      # filters = {
      #   lesser_than: 30,
      #   greater_than: 40,
      #   equal_to: 40,
      #   like: "old",
      #   different: "different than this",
      #   includes: ["test", "this", "tomorrow"],
      #   excludes: ["test", "this", "tomorrow"]
      # }

      filters.each do |operation, content|
        operation = operation.to_s

        statement += " AND " unless statement.empty?

        field_id = ActiveRecord::Base.sanitize(field_id.to_i)

        case operation
        when "lesser_than"
          content = ActiveRecord::Base.sanitize(content)
          statement += "(inventory_item_data.inventory_field_id = #{field_id} AND CAST(inventory_item_data.content[1] AS float) < CAST(#{content} AS float))"
        when "greater_than"
          content = ActiveRecord::Base.sanitize(content)
          statement += "(inventory_item_data.inventory_field_id = #{field_id} AND CAST(inventory_item_data.content[1] AS float) > CAST(#{content} AS float))"
        when "equal_to"
          content = ActiveRecord::Base.sanitize(content)
          statement += "(inventory_item_data.inventory_field_id = #{field_id} AND inventory_item_data.content[1] = #{content})"
        when "like"
          content = ActiveRecord::Base.sanitize("%#{content}%")
          statement += "(inventory_item_data.inventory_field_id = #{field_id} AND inventory_item_data.content[1] LIKE #{content})"
        when "different"
          content = ActiveRecord::Base.sanitize(content)
          statement += "(inventory_item_data.inventory_field_id = #{field_id} AND inventory_item_data.content[1] != #{content})"
        when "includes"
          content = content.inject([]) { |s, (k, v)| s << v }

          content = "{#{content.join(",")}}"
          content = ActiveRecord::Base.sanitize(content)
          statement += "(inventory_item_data.inventory_field_id = #{field_id} AND inventory_item_data.content @> #{content}::text[])"
        when "excludes"
          content = content.inject([]) { |s, (k, v)| s << v }

          content = "{#{content.join(",")}}"
          content = ActiveRecord::Base.sanitize(content)
          statement += "(inventory_item_data.inventory_field_id = #{field_id} AND NOT(inventory_item_data.content @> #{content}::text[]))"
        end
      end
    end

    statement
  end
end
