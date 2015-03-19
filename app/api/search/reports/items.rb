module Search::Reports::Items
  class API < Grape::API
    desc "Search for report items"
    paginate per_page: 25
    params do
      optional :begin_date, type: DateTime
      optional :end_date, type: DateTime
      optional :query, type: String, desc: "Query for name of the user, title and protocol"
      optional :statuses_ids, type: String,
               desc: 'Statuses ids, format: "3,5,7"'
      optional :users_ids, type: String,
               desc: 'User ids, format: "3,5,7"'
      optional :reports_categories_ids, type: String,
               desc: 'Categories ids, format: "3,5,7"'
      optional :address, type: String
      optional :position, type: Hash,
               desc: 'Position parameters for search'
      optional :overdue, type: Boolean,
               desc: 'Rerturn only overdue or not overdue reports'
      optional :sort, type: String,
               desc: 'The field to sort the items. Either created_at, updated_at, status, id, reports_status_id (for status ordering) or user_name'
      optional :order, type: String,
               desc: 'The order, can be `desc` or `asc`'
      optional :display_type, type: String,
               desc: "Could be 'full'"
      optional :clusterize, type: String,
               desc: 'Should clusterize the results or not'
      optional :zoom, type: Integer,
               desc: 'Zooming level of the map'
    end
    get "reports/items" do
      authenticate!

      search_params = safe_params.permit(
        :begin_date, :end_date, :address, :query, :overdue, :clusterize,
        :zoom, :position => [:latitude, :longitude, :distance]
      )

      search_params[:paginator] = method(:paginate)
      search_params[:page] = safe_params[:page]
      search_params[:per_page] = safe_params[:per_page]

      unless safe_params[:reports_categories_ids].blank?
        search_params[:category] = safe_params[:reports_categories_ids].split(',').map do |category_id|
          Reports::Category.find(category_id)
        end
      end

      unless safe_params[:users_ids].blank?
        search_params[:user] = safe_params[:users_ids].split(',').map do |user_id|
          User.find(user_id)
        end
      end

      search_params[:begin_date] = safe_params[:begin_date]
      search_params[:end_date] = safe_params[:end_date]

      if safe_params[:statuses_ids].present?
        search_params[:statuses] = safe_params[:statuses_ids].split(',').map do |status_id|
          Reports::Status.find(status_id)
        end
      end

      search_params[:sort] = safe_params[:sort]
      search_params[:order] = safe_params[:order]

      results = Reports::SearchItems.new(current_user, search_params).search

      if safe_params[:clusterize]
        header('Total', results[:total].to_s)

        {
          reports: Reports::Item::Entity.represent(results[:reports], only: return_fields, display_type: safe_params[:display_type]),
          clusters: Reports::Cluster::Entity.represent(results[:clusters])
        }
      else
        {
          reports: Reports::Item::Entity.represent(results, only: return_fields,
                                                  display_type: safe_params[:display_type],
                                                  user: current_user)
        }
      end


    end

    desc "Search for report items on given category and status"
    paginate per_page: 25
    params do
      optional :address
      optional :description
    end

    get "reports/:category_id/status/:status_id/items" do
      authenticate!

      report_category = Reports::Category.find(safe_params[:category_id])
      status = Reports::Status.find(safe_params[:status_id])

      reports = Reports::Item.includes(:status).where(
        reports_category_id: report_category.id,
        reports_status_id: status.id
      )

      reports = reports.fuzzy_search({
        address: safe_params[:address],
        description:   safe_params[:description]
      }, false)

      reports = paginate(reports)

      {
        reports: Reports::Item::Entity.represent(reports,
                                                 user: current_user)
      }
    end
  end
end
