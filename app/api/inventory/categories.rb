module Inventory::Categories
  class API < Grape::API
    resources :categories do
      desc "List all categories"
      paginate(per_page: 25)
      params do
        optional :title, type: String, desc: "Category's name for search"
        optional :display_type, type: String, desc: "Display type for the categories"
      end
      get do
        validate_permission!(:view, Inventory::Category)

        title = safe_params[:title]
        permissions = UserAbility.new(current_user)

        if permissions.can?(:manage, Inventory::Category)
          categories = Inventory::Category.all
        else
          categories = Inventory::Category.where(id: permissions.inventory_categories_visible)
        end

        if title
          categories = categories.fuzzy_search(title: "%#{title}%")
        end

        {
          categories: Inventory::Category::Entity.represent(
            paginate(categories),
            user: current_user,
            display_type: 'full'
          )
        }
      end

      desc "Create an category"
      params do
        requires :title, type: String, desc: "Category's name"
        optional :description, type: String, desc: "Category's short description"
        requires :plot_format, type: String, desc: "The format of plotting, can be 'marker' or 'pin'"
        requires :icon, type: String,
          desc: 'The icon that represents this category. Used for listing.'
        requires :color, type: String,
          desc: 'Color of the category'
        optional :require_item_status, type: Boolean,
          desc: 'Defines if item of category should have a status'
        optional :sections, type: Array, desc: "An array of sections and it's fields"
        optional :statuses, type: Array, desc: "An array of statuses, fields required: title and color"
        optional :groups_can_view, type: Array, desc: "An array of groups ids"
        optional :groups_can_edit, type: Array, desc: "An array of groups ids"
      end
      post do
        authenticate!
        validate_permission!(:create, Inventory::Category)

        category_params = safe_params.permit(
          :title, :description, :color, :plot_format,
          :icon, :require_item_status, :private
        )

        category_params[:marker] = safe_params[:icon]
        category_params[:pin] = safe_params[:icon]

        if safe_params[:statuses]
          category_params[:statuses_attributes] = safe_params[:statuses]
        end

        category = Inventory::Category.new(category_params)
        category.save!

        if safe_params[:section].present?
          creator = Inventory::CreateFormForCategory.new(category, safe_params)
          creator.create!
        end

        permissions = safe_params[:permissions]
        if permissions
          groups_can_view = permissions[:groups_can_view]
          groups_can_edit = permissions[:groups_can_edit]
        end

        Groups::UpdatePermissions.update(groups_can_view, category, :inventory_categories_can_view)
        Groups::UpdatePermissions.update(groups_can_edit, category, :inventory_categories_can_edit)

        {
          message: "Category created with success",
          category: Inventory::Category::Entity.represent(category, user: current_user)
        }
      end

      desc "Shows category's info"
      params do
        optional :display_type, type: String,
                 desc: 'If "full", returns additional control properties.'
      end
      get ':id' do
        category = Inventory::Category.find(safe_params[:id])
        validate_permission!(:view, category)

        {
          category: Inventory::Category::Entity.represent(
            category,
            display_type: safe_params[:display_type],
            user: current_user
          )
        }
      end

      desc "Destroy category"
      delete ':id' do
        authenticate!

        category = Inventory::Category.find(safe_params[:id])
        validate_permission!(:delete, category)
        category.destroy

        { message: "Category deleted successfully" }
      end

      desc "Update category's info"
      params do
        optional :title, type: String, desc: "Category's title"
        optional :description, type: String, desc: "Category's title"
        optional :plot_format, type: String, desc: "The format of plotting, can be 'marker' or 'pin'"
        optional :icon, type: String,
          desc: 'The icon that represents this category. Used for listing.'
        optional :color, type: String, desc: 'Color of the category'
        optional :require_item_status, type: Boolean,
          desc: 'Defines if item of category should have a status'
        optional :groups_can_view, type: Array, desc: "An array of groups ids"
        optional :groups_can_edit, type: Array, desc: "An array of groups ids"
      end
      put ':id' do
        authenticate!

        category = Inventory::Category.find(safe_params[:id])
        validate_permission!(:edit, category)

        category_params = safe_params.permit(
          :title, :description, :color, :plot_format,
          :require_item_status, :private
        )
        category_params = category_params.merge(
          icon: params[:icon],
          marker: params[:icon],
          pin: params[:icon],
        )

        category.update!(category_params)
        category.reload

        if params[:icon] || params[:color]
          begin
            category.icon.cache_stored_file!
            category.icon.retrieve_from_cache!(category.icon.cache_name)
            category.icon.recreate_versions!

            category.pin.cache_stored_file!
            category.pin.retrieve_from_cache!(category.pin.cache_name)
            category.pin.recreate_versions!

            category.marker.cache_stored_file!
            category.marker.retrieve_from_cache!(category.marker.cache_name)
            category.marker.recreate_versions!

            category.save!
          rescue NoMethodError => e
          end
        end

        permissions = safe_params[:permissions]

        if permissions
          groups_can_view = permissions[:groups_can_view]
          groups_can_edit = permissions[:groups_can_edit]
        end

        Groups::UpdatePermissions.update(groups_can_view, category, :inventory_categories_can_view)
        Groups::UpdatePermissions.update(groups_can_edit, category, :inventory_categories_can_edit)

        {
          message: "Category updated successfully",
          category: Inventory::Category::Entity.represent(category, user: current_user)
        }
      end

      desc "Changes the form for the category"
      params do
        requires :sections, type: Array, desc: "An array of sections and it's fields"
      end
      put ':id/form' do
        authenticate!
        category = Inventory::Category.find(safe_params.delete(:id))
        validate_permission!(:edit, category)

        if !category.locked? || (category.locked? && category.locker == current_user)
          creator = Inventory::CreateFormForCategory.new(category, safe_params)
          creator.create!

          form = Inventory::RenderCategoryFormData.new(category).render

          {
            message: "Form updated successfully!",
            form: form
          }
        else
          {
            message: "Form locked",
            locker: User::Entity.represent(category.locker),
            locked_at: category.locked_at
          }
        end
      end

      desc "Get the form structure for category"
      get ':id/form' do
        authenticate!
        category = Inventory::Category.find(safe_params[:id])
        validate_permission!(:edit, category)

        Inventory::RenderCategoryFormData.new(category).render
      end

      desc "Update the access to the inventory category, locking it"
      patch ':id/update_access' do
        authenticate!

        category = Inventory::Category.find(safe_params[:id])
        validate_permission!(:edit, category)

        Inventory::CategoryLocking.new(category, current_user).lock!
      end
    end
  end
end
