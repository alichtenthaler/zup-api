module Inventory::Items
  class API < Grape::API
    helpers do
      def load_category(inventory_category_id = nil)
        Inventory::Category.find(inventory_category_id || safe_params[:category_id])
      end
    end

    # Lists/searches for inventory items
    # /inventory/items
    resources :items do
      desc "List all items"
      paginate per_page: 25
      params do
        optional :position, type: Hash,
          desc: "Hash of position data"
        optional :inventory_category_id,
          desc: "ID (or array of ids of the desired inventory category"
        optional :limit, type: Integer,
               desc: 'The maximum number to reports to return'
        optional :sort, type: String,
                 desc: 'The field to sort the items. Either created_at, updated_at or id'
        optional :order, type: String,
                 desc: 'Either ASC or DESC.'
      end
      get do
        search_params = {
          filters: safe_params[:filters],
          position: safe_params[:position],
          limit: safe_params[:limit],
          sort: safe_params[:sort],
          order: safe_params[:order]
        }

        unless safe_params[:inventory_category_id].blank?
          if safe_params[:inventory_category_id].is_a?(Array)
            search_params[:categories] = safe_params[:inventory_category_id].map do |cid|
              Inventory::Category.find(cid)
            end
          else
            search_params[:categories] = [Inventory::Category.find(safe_params[:inventory_category_id])]
          end
        end

        items = Inventory::SearchItems.new(search_params).search
        if safe_params[:position].nil?
          items = paginate(items)
        end

        garner.bind(Inventory::ItemCacheControl.new(items)).options(expires_in: 15.minutes) do
          { items: Inventory::Item::Entity.represent(items, serializable: true) }
        end
      end
    end

    # /inventory/categories/:category_id/items
    resources :categories do
      route_param :category_id do
        resources :items do
          desc "Create an item"
          params do
            optional :title, type: String
            optional :inventory_status_id, type: Integer
            requires :data
          end
          post do
            authenticate!
            validate_permission!(:create, Inventory::Item)

            category = load_category

            if safe_params[:inventory_status_id]
              status = category.statuses.find(safe_params[:inventory_status_id])
            end

            creator = Inventory::CreateItemFromCategoryForm.new(
              category: category,
              user: current_user,
              data: safe_params["data"],
              status: status
            )
            item = creator.create!

            {
              message: "Item created successfully",
              item: Inventory::Item::Entity.represent(item)
            }
          end

          desc "Shows item's info"
          get ':id' do
            category = load_category
            item = category.items.find(safe_params[:id])

            { item: Inventory::Item::Entity.represent(item) }
          end

          desc "Destroy item"
          delete ':id' do
            authenticate!
            category = load_category

            item = category.items.find(safe_params[:id])
            validate_permission!(:destroy, item)
            item.destroy!

            { message: "Inventory item successfully destroyed!" }
          end

          desc "Update item's info"
          params do
            optional :data, type: Hash, desc: "The item data where each element is a content for a category field"
            optional :inventory_status_id, type: Integer,
                     desc: "The inventory status you want"
          end
          put ':id' do
            authenticate!

            category = load_category
            item = category.items.find(safe_params[:id])
            validate_permission!(:edit, item)

            if safe_params[:data]
              updater = Inventory::UpdateItemFromCategory.new(item, safe_params[:data])
              item = updater.update!
            end

            if safe_params[:inventory_status_id]
              status = category.statuses.find(safe_params[:inventory_status_id])
              item.reload.update!(status: status)
            end

            { message: "Inventory item updated successfully!" }
          end
        end
      end
    end
  end
end
