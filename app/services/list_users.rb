class ListUsers
  AVAILABLE_SORT_FIELDS = ['name', 'username', 'email', 'phone', 'created_at', 'updated_at']

  attr_reader :order, :sort, :name, :email,
              :groups, :scope, :search_params,
              :like

  def initialize(opts = {})
    @name = opts[:name]
    @email = opts[:email]
    @groups = opts[:groups] || []
    @like = opts[:like] || false
    @order = opts[:order]
    @sort = opts[:sort]

    @search_params = {}

    @scope = User.distinct

    unless opts[:disabled]
      @scope = @scope.enabled
    end
  end

  def fetch
    build_ordering_search
    build_name_search
    build_email_search
    build_group_search

    if like
      do_like_search
    else
      do_common_search
    end

    scope
  end

  private

  def build_ordering_search
    if sort &&
      sort.in?(AVAILABLE_SORT_FIELDS) &&
      %w(desc asc).include?(order.downcase)
      @scope = scope.order("#{sort.to_sym} #{order.to_sym}")
    end
  end

  def build_name_search
    if name
      @search_params = search_params.merge(
        name: @name
      )
    end
  end

  def build_email_search
    if email
      @search_params = search_params.merge(
        email: @email
      )
    end
  end

  def build_group_search
    if groups.any?
      groups_ids = groups.map(&:id)
      @scope = scope.joins(:groups).where('groups.id IN (?)', groups_ids)
    end
  end

  def do_like_search
    if @search_params.any?
      @scope = scope.like_search(@search_params)
    end
  end

  def do_common_search
    if @search_params.any?
      @scope = scope.fuzzy_search(@search_params)
    end
  end
end
