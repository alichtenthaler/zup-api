require "grape/validators/category_status"

module Reports::Categories
  class API < Grape::API
    resource :categories do
      desc 'Creates a new report category'
      params do
        requires :title, type: String,
                 desc: 'The report category title'

        requires :icon, type: String,
                 desc: 'The icon that represents this category. Used for listing.'

        requires :marker, type: String,
                 desc: 'The marker used on the map for reports of this category.'

        requires :statuses, category_status: true,
                 desc: 'A JSON hash of statuses that reports from this categories allows.
                 Accepts the properties: title [String], color [#hexa String], initial [Bool] and final [Bool]'

        requires :color, type: String,
                 desc: 'A hex color string that will be used as background color for the icons ' +
                 'and markers of this category'

        optional :resolution_time, type: Integer,
                 desc: 'The time this kind of report takes to be solved, in seconds.'

        optional :private_resolution_time, type: Boolean,
                 desc: 'If the resolution time should be private for the public user'

        optional :resolution_time_enabled, type: Boolean,
                 desc: 'If the resolution time is enabled or not for the category'

        optional :user_response_time, type: Integer,
                 desc: 'How long the user is allowed to comment on this report after ' +
                 'it has been marked as resolved, in seconds'

        optional :allows_arbitrary_position, type: Boolean,
                 desc: 'Whether or not to allow the user to set a custom marker location for the reports of this category'

        optional :inventory_categories, type: Array,
                 desc: 'Array of related inventory categories'

        optional :parent_id, type: Integer,
                 desc: 'The id of a parent category (this will become a subcategory)'

        optional :confidential, type: Boolean,
                 desc: 'If the reports created on this category are confidential or not'
      end

      post do
        authenticate!
        validate_permission!(:create, Reports::Category)

        safe_params[:marker] = safe_params[:icon]

        category_params = safe_params.permit(
          :title, :allows_arbitrary_position,
          :resolution_time, :user_response_time, :color,
          :icon, :marker, :parent_id, :private, :confidential,
          :private_resolution_time, :resolution_time_enabled
        )

        if safe_params[:inventory_categories]
          category_params = category_params.merge(
            inventory_category_ids: safe_params[:inventory_categories]
          )
        end

        Reports::Category.transaction do
          category = Reports::Category.create!(category_params)
          statuses = []

          params[:statuses].each do |k, status|
            statuses << status
          end

          category.update_statuses!(statuses)

          {
            category: Reports::Category::Entity.represent(
              category, display_type: :full
            )
          }
        end

      end

      desc 'Return information about the given category'
      params do
        requires :id, type: Integer, desc: 'The report category ID'
      end
      get ':id' do
        report_category = Reports::Category.find(params[:id])
        validate_permission!(:view, report_category)

        display_type = params[:display_type].nil? ? :full : params[:display_type].to_s.to_sym
        { category: Reports::Category::Entity.represent(report_category, display_type: display_type) }
      end

      desc 'Returns list of all reports category'
      paginate per_page: 25
      params do
        optional :display_type, type: String,
                 desc: 'If "full", returns additional control properties.'
      end
      get do
        display_type = params[:display_type] == 'full' ? :full : :default
        categories_scope = Reports::Category.active.main
        permissions = UserAbility.new(current_user)

        unless permissions.can?(:manage, Inventory::Category)
          categories_scope = categories_scope.where(id: permissions.reports_categories_visible)
        end

        {
          categories: Reports::Category::Entity.represent(
            paginate(categories_scope),
            display_type: display_type
          )
        }
      end

      desc 'Updates a report category'
      params do
        requires :id, type: Integer, desc: "The category's ID"
      end
      put ':id' do
        authenticate!

        params[:marker] = params[:icon]

        category_params = safe_params.permit(
          :title, :allows_arbitrary_position,
          :resolution_time, :user_response_time, :color,
          :parent_id, :confidential, :icon, :marker,
          :private_resolution_time, :resolution_time_enabled,
          :statuses
        )

        if safe_params[:inventory_categories]
          category_params = category_params.merge(
            inventory_category_ids: safe_params[:inventory_categories]
          )
        end

        category = Reports::Category.find(params[:id])
        validate_permission!(:create, category)

        Reports::Category.transaction do
          category.update!(category_params)

          unless params[:statuses].nil?
            statuses = []

            params[:statuses].each do |k, status|
              statuses << status
            end

            category.update_statuses!(statuses)
          end

          if safe_params[:icon] || safe_params[:marker] || safe_params[:color]
            category.icon.recreate_versions!
            category.marker.recreate_versions!
            category.save!
          end
        end

        status 204
      end

      desc 'Destroy a report category'
      delete ':id' do
        authenticate!

        category = Reports::Category.find(params[:id])
        validate_permission!(:destroy, category)
        category.destroy

        status 204
      end
    end
  end
end
