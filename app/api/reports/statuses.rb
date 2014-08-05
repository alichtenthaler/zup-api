require "grape/validators/category_status"

module Reports::Statuses
  class API < Grape::API

    helpers do
      def load_category
        Reports::Category.find(params[:category_id])
      end
    end

    namespace 'categories/:category_id/statuses' do
      desc "Return all category's statuses"
      get do
        validate_permission!(:view, Reports::Category)

        category = load_category
        statuses = category.statuses

        {
          statuses: Reports::Status::Entity.represent(statuses)
        }
      end

      desc "Create a status for the reports category"
      params do
        requires :title, type: String, desc: "The status title (maximum 160)"
        requires :color, type: String, desc: "Color in hexadecimal format"
        requires :initial, type: String, desc: "If the status is initial"
        requires :final, type: String, desc: "If the status is final"
        optional :active, type: String, desc: "If the status is active to use"
      end
      post do
        validate_permission!(:edit, Reports::Category)

        status_params = safe_params.permit(:title, :color, :initial, :final, :active)

        category = load_category
        status = category.statuses.create!(status_params)

        {
          status: Reports::Status::Entity.represent(status)
        }
      end

      desc "Update status for the category"
      params do
        optional :title, type: String, desc: "The status title (maximum 160)"
        optional :color, type: String, desc: "Color in hexadecimal format"
        optional :initial, type: String, desc: "If the status is initial"
        optional :final, type: String, desc: "If the status is final"
        optional :active, type: String, desc: "If the status is active to use"
      end
      put ':id' do
        validate_permission!(:edit, Reports::Category)

        status_params = safe_params.permit(:title, :color, :initial, :final, :active)

        category = load_category
        status = category.statuses.find(safe_params[:id])
        status.update!(status_params)

        {
          status: Reports::Status::Entity.represent(category.reload.statuses)
        }
      end

      desc "Delete status of category"
      delete ':id' do
        validate_permission!(:destroy, Reports::Category)

        category = load_category
        status = category.statuses.find(safe_params[:id])
        status.destroy!
      end
    end

  end
end
