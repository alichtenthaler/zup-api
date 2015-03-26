module Reports::Items
  class API < Grape::API
    desc 'Creates a new report'
    params do
      requires :category_id, type: Integer,
               desc: 'The ID of the desired report category'
      optional :inventory_item_id, type: Integer,
               desc: 'The ID of the inventory item for this report. If blank, latitude and longitude are mandatory.'
      optional :latitude, type: String,
               desc: 'The latitude for the custom location of this report. Ignored if an inventory item is given.'
      optional :longitude, type: String,
               desc: 'The longitude for the custom location of this report. Ignored if an inventory item is given.'
      optional :description, type: String,
               desc: 'The report description'
      # TODO: Geocode the address if not given and lat/long are present
      optional :address, type: String,
               desc: 'The complete address for this report.'
      optional :reference, type: String,
               desc: 'The reference for the address'
      optional :images, type: Array,
               desc: 'An array of images(post data or encoded on base64) for this report.'
      optional :status_id, type: Integer,
               desc: 'The new status id'
      optional :user_id, type: Integer,
               desc: 'An user id to associate with it'
      optional :confidential, type: Boolean,
               desc: 'If the report is confidential or not'
      optional :from_panel, type: Boolean,
               desc: 'If the report is coming from the panel this should be true'
    end
    post ':category_id/items' do
      authenticate!
      category = Reports::Category.find(params[:category_id])

      report_params = safe_params.permit(:description, :address, :reference, :confidential)

      Reports::Item.transaction do
        if params[:user_id]
          validate_permission!(:edit, Reports::Item)
          author = User.find(params[:user_id])
        else
          author = current_user
        end

        reporter = current_user

        report = Reports::Item.new(
          report_params.merge(category: category, user: author, reporter: reporter)
        )

        # Permission validation
        if safe_params.delete(:from_panel)
          validate_permission!(:create_from_panel, report)
        else
          validate_permission!(:create, report)
        end

        if params[:inventory_item_id]
          report.inventory_item = Inventory::Item.find(params[:inventory_item_id])
        elsif params[:latitude] && params[:longitude] && params[:address]
          report.position = Reports::Item.rgeo_factory.point(params[:longitude], params[:latitude])
          report.address = params[:address]
        else
          error!('Either an inventory item or latitude, longitude and address must be provided.', 400)
        end

        report.update_images(params[:images]) if params[:images]
        report.save!

        if params[:inventory_item_id]
          Inventory::CreateHistoryEntry.new(report.inventory_item, current_user)
                                       .create('report',
                                               'Criou uma solicitação para este item de inventário.',
                                               report)
        end

        if report.user
          Reports::NotifyUser.new(report).notify_report_creation!
        end

        if Webhook.enabled?
          SendReportThroughWebhook.perform_async(report.id)
        end

        { report: Reports::Item::Entity.represent(report, display_type: 'full', user: current_user, only: return_fields) }
      end
    end

    desc 'Updates a report'
    params do
      optional :category_id, type: Integer,
               desc: 'The ID of the reports category of the report'
      optional :inventory_item_id, type: Integer,
               desc: 'The ID of the inventory item for this report. If blank, latitude and longitude are mandatory.'
      optional :latitude, type: String,
               desc: 'The latitude for the custom location of this report. Ignored if an inventory item is given.'
      optional :longitude, type: String,
               desc: 'The longitude for the custom location of this report. Ignored if an inventory item is given.'
      optional :description, type: String,
               desc: 'The report description'
      optional :address, type: String,
               desc: 'The complete address for this report.'
      optional :reference, type: String,
               desc: 'The reference for the address'
      optional :status_id, type: String,
               desc: 'The new status of the item'
      optional :images, type: Array,
               desc: 'An array of images(post data or encoded on base64) for this report.'
      optional :confidential, type: Boolean,
               desc: 'If the report is confidential or not'
    end
    put ':reports_category_id/items/:id' do
      authenticate!

      category = Reports::Category.find(safe_params[:reports_category_id])
      report = Reports::Item.find_by!(id: safe_params[:id], reports_category_id: category.id)

      validate_permission!(:edit, report)

      Reports::Item.transaction do
        report_params = safe_params.permit(:description, :address, :reference, :confidential)

        if safe_params[:category_id].present?
          new_category = Reports::Category.find(safe_params[:category_id])
          report_params = report_params.merge(
            category: new_category
          )
        end

        report.attributes = report_params

        if params[:inventory_item_id]
          report.inventory_item = Inventory::Item.find(
            params[:inventory_item_id]
          )
        elsif params[:latitude] && params[:longitude] && params[:address]
          report.position = Reports::Item.rgeo_factory.point(
            params[:longitude], params[:latitude]
          )
          report.address = params[:address]
        end

        report.update_images(params[:images]) if params[:images]
        report.save!

        if params[:status_id]
          new_status = category.statuses.find(params[:status_id])
          Reports::UpdateItemStatus.new(report, current_user).update_status!(new_status)
        end

        {
          report: Reports::Item::Entity.represent(
            report, display_type: 'full', user: current_user
          )
        }
      end
    end

    desc 'Change migration'
    params do
      optional :new_category_id, type: Integer,
               desc: 'The id of the new reports category of the report'
      optional :new_status_id, type: Integer,
               desc: 'The id of the new status of the new category to change'
    end
    put ':reports_category_id/items/:id/change_category' do
      authenticate!

      category = Reports::Category.find(safe_params[:reports_category_id])
      new_category = Reports::Category.find(safe_params[:new_category_id])
      item = Reports::Item.find_by!(id: safe_params[:id], reports_category_id: category.id)

      validate_permission!(:edit, item)

      new_status = new_category.statuses.find(safe_params[:new_status_id])

      # Move to new category and status
      service = Reports::ChangeItemCategory.new(item, new_category, new_status, current_user)
      service.process!

      {
        report: Reports::Item::Entity.represent(
          item, display_type: 'full', user: current_user
        )
      }
    end

    # #####################
    # Endpoints for listing
    # #####################

    # TODO: remove other options for searching, make this the only
    # endpoint for listing reports.
    # TODO: Move this to a namespace "items"
    desc 'Retrieve a list of reports, you can use a list of params do filter'
    paginate per_page: 25
    params do
      optional :inventory_item_id, type: Integer,
               desc: 'Inventory item id to filter for'
      optional :category_id, type: Integer,
               desc: 'Report category to filter for'
      optional :user_id, type: Integer,
               desc: 'User id to filter for'
      optional :begin_date, type: DateTime,
               desc: 'The minimum date to filter'
      optional :end_date, type: DateTime,
               desc: 'The maximum date to filter'
      optional :statuses,
               desc: "Statuses id to filter, you can
               pass a single id or an array of ids"
      optional :display_type, type: String,
               desc: 'Display type for report data'
      optional :limit, type: Integer,
               desc: 'The maximum number to reports to return'
      optional :sort, type: String,
               desc: 'The field to sort the items. Either created_at, updated_at, id, reports_status_id or user_name'
      optional :order, type: String,
               desc: 'Either ASC or DESC.'
      optional :clusterize, type: String,
               desc: 'Should clusterize the results or not'
    end
    get 'items' do
      if safe_params[:category_id]
        category = Reports::Category.find(safe_params[:category_id])
      end

      if safe_params[:user_id]
        user = User.find(safe_params[:user_id])
      end

      if safe_params[:inventory_item_id]
        inventory_item = Inventory::Item.find(safe_params[:inventory_item_id])
      end

      if safe_params[:begin_date]
        begin_date = safe_params[:begin_date]
      end

      if safe_params[:end_date]
        end_date = safe_params[:end_date]
      end

      if safe_params[:statuses]
        if safe_params[:statuses].is_a? Array
          statuses = safe_params[:statuses].map do |status_id|
            Reports::Status.find(status_id)
          end
        else
          statuses = [Reports::Status.find(safe_params[:statuses])]
        end
      end

      reports = Reports::SearchItems.new(
        current_user,
        category: category,
        user: user,
        inventory_item: inventory_item,
        position: safe_params[:position],
        statuses: statuses,
        begin_date: begin_date,
        end_date: end_date,
        group_by_inventory_item: true,
        limit: safe_params[:limit],
        sort: safe_params[:sort],
        order: safe_params[:order],
        paginator: method(:paginate),
        page: safe_params[:page],
        per_page: safe_params[:per_page],
        clusterize: safe_params[:clusterize]
      )

      reports = reports.search

      garner.bind(Reports::ItemCacheControl.new(reports)).options(expires_in: 15.minutes) do
        {
          reports: Reports::Item::Entity.represent(
            reports,
            display_type: safe_params[:display_type],
            user: current_user,
            only: return_fields,
            serializable: true
          )
        }
      end
    end

    # TODO: Move to a namespace "items"
    desc 'Returns data for report'
    params do
      optional :display_type, type: String,
               desc: 'Display type for report data'
      requires :id, type: Integer, desc: "The report's ID"
    end
    get 'items/:id' do
      report = Reports::Item.find(safe_params[:id])

      {
        report: Reports::Item::Entity.represent(
          report,
          user: current_user,
          only: return_fields,
          display_type: 'full'
        )
      }
    end

    desc 'Destroy a report item'
    params do
      requires :id, type: Integer, desc: "The report's ID"
    end
    delete 'items/:id' do
      authenticate!

      report = Reports::Item.find(params[:id])
      validate_permission!(:delete, report)

      if report.destroy
        status 204
      else
        status 422
      end
    end

    desc 'Retrieve a list of reports assigned to the given category'
    paginate per_page: 25
    params do
      requires :category_id, type: Integer,
               desc: 'The report category ID'
      optional :position, type: Hash,
               desc: 'Position parameters for search'
      optional :display_type, type: String,
               desc: 'Display type for report'
      optional :limit, type: Integer,
               desc: 'The maximum number to reports to return'
      optional :sort, type: String,
               desc: 'The field to sort the items. Either created_at, updated_at or id'
      optional :order, type: String,
               desc: 'Either ASC or DESC.'
    end
    get ':category_id/items' do
      category = Reports::Category.find(params[:category_id])
      position = safe_params[:position]
      reports  = Reports::SearchItems.new(
        current_user,
        category: category,
        position: position,
        limit: safe_params[:limit],
        sort: safe_params[:sort],
        order: safe_params[:order],
        paginator: method(:paginate)
      ).search

      {
        reports: Reports::Item::Entity.represent(
          reports,
          user: current_user,
          only: return_fields,
          display_type: safe_params[:display_type]
        )
      }
    end

    desc 'Retrieve a list of reports assigned to the given inventory item'
    paginate per_page: 25
    params do
      requires :inventory_item_id, type: Integer,
               desc: 'The inventory item ID'
      optional :position, type: Hash,
               desc: 'Position parameters for search'
      optional :display_type, type: String,
               desc: 'Display type for report'
      optional :limit, type: Integer,
               desc: 'The maximum number to reports to return'
    end
    get 'inventory/:inventory_item_id/items' do
      item = Inventory::Item.find(params[:inventory_item_id])
      position = safe_params[:position]
      reports  = Reports::SearchItems.new(
        current_user,
        inventory_item: item,
        position: position,
        limit: safe_params[:limit],
        sort: safe_params[:sort],
        order: safe_params[:order],
        paginator: method(:paginate)
      ).search

      {
        reports: Reports::Item::Entity.represent(
          reports,
          user: current_user,
          only: return_fields,
          display_type: safe_params[:display_type]
        )
      }
    end

    desc 'Retrieve a list of reports assigned to the current user'
    paginate per_page: 25
    params do
      optional :display_type, type: String,
               desc: 'Display type for report'
      optional :position, type: Hash,
               desc: 'Position parameters for search'
      optional :limit, type: Integer,
               desc: 'The maximum number to reports to return'
    end
    get 'users/me/items' do
      authenticate!

      position = safe_params[:position]
      reports  = Reports::SearchItems.new(
        current_user,
        user: current_user,
        position: position,
        limit: safe_params[:limit]
      ).search

      total_reports_by_user = current_user.reports.count

      {
        reports: Reports::Item::Entity.represent(
          reports,
          user: current_user,
          only: return_fields,
          display_type: 'full'
        ),
        total_reports_by_user: total_reports_by_user
      }
    end

    desc 'Retrieve a list of reports assigned to the given user'
    paginate per_page: 25
    params do
      requires :user_id, type: Integer,
               desc: 'The user id'
      optional :display_type, type: String,
               desc: 'Display type for report item'
      optional :position, type: Hash,
               desc: 'Position parameters for search'
      optional :limit, type: Integer,
               desc: 'The maximum number to reports to return'
    end
    get 'users/:user_id/items' do
      user = User.find(params[:user_id])
      position = safe_params[:position]
      reports  = Reports::SearchItems.new(
        current_user,
        user: user,
        position: position,
        limit: safe_params[:limit]
      ).search

      total_reports_by_user = user.reports.count

      {
        reports: Reports::Item::Entity.represent(
          reports,
          only: return_fields,
          user: current_user,
          display_type: 'full'
        ),
        total_reports_by_user: total_reports_by_user
      }
    end
  end
end
