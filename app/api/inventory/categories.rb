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

        if title
          categories = Inventory::Category.fuzzy_search(title: "%#{title}%")
        else
          categories = Inventory::Category.all.load
        end

        {
          categories: Inventory::Category::Entity.represent(
            paginate(categories),
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
      end
      post do
        authenticate!
        validate_permission!(:create, Inventory::Category)

        category_params = safe_params.permit(
          :title, :description, :color, :plot_format,
          :icon, :require_item_status
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

        {
          message: "Category created with success",
          category: Inventory::Category::Entity.represent(category)
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

        { category: Inventory::Category::Entity.represent(category, display_type: safe_params[:display_type]) }
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
      end
      put ':id' do
        authenticate!

        category = Inventory::Category.find(safe_params[:id])
        validate_permission!(:edit, category)

        category_params = safe_params.permit(
          :title, :description, :color, :plot_format,
          :require_item_status
        )
        category_params = category_params.merge(
          icon: params[:icon],
          marker: params[:icon],
          pin: params[:icon],
        )

        category.update!(category_params)
        category.reload
        category.icon.recreate_versions!
        category.pin.recreate_versions!
        category.marker.recreate_versions!

        {
          message: "Category updated successfully",
          category: Inventory::Category::Entity.represent(category)
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

        creator = Inventory::CreateFormForCategory.new(category, safe_params)
        creator.create!

        { message: "Form updated successfully!" }
      end

      desc "Get the form structure for category"
      get ':id/form' do
        authenticate!
        category = Inventory::Category.find(safe_params[:id])
        validate_permission!(:edit, category)

        Inventory::RenderCategoryFormData.new(category).render
      end
    end
  end
end
