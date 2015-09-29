module Reports::Statuses
  class API < Base::API
    helpers do
      def load_category
        Reports::Category.find(params[:category_id])
      end
    end

    namespace 'categories/:category_id/statuses' do
      desc "Return all category's statuses"
      params do
        optional :deactivated, type: Boolean
      end
      get do
        validate_permission!(:view, Reports::Category)

        category = load_category
        statuses = category.status_categories

        unless params[:deactivated]
          statuses = statuses.active
        end

        {
          statuses: Reports::StatusCategory::Entity.represent(statuses, only: return_fields)
        }
      end

      desc 'Create a status for the reports category'
      params do
        requires :title, type: String, desc: 'The status title (maximum 160)'
        requires :color, type: String, desc: 'Color in hexadecimal format'
        requires :initial, type: Boolean, desc: 'If the status is initial'
        requires :final, type: Boolean, desc: 'If the status is final'
        optional :active, type: Boolean, desc: 'If the status is active to use'
        optional :private, type: Boolean, desc: 'If the status is private or not'
      end
      post do
        validate_permission!(:edit, Reports::Category)

        status_params = {
          title: params[:title]
        }

        status_category_params = {
          initial: params[:initial],
          final: params[:final],
          active: params[:active],
          private: params[:private],
          color: params[:color]
        }

        category = load_category
        status = Reports::Status.find_or_create_by!(status_params)

        category.status_categories.create!(
          status_category_params.merge(status: status)
        )

        {
          status: Reports::Status::Entity.represent(status, only: return_fields)
        }
      end

      desc 'Update status for the category'
      params do
        optional :title, type: String, desc: 'The status title (maximum 160)'
        optional :color, type: String, desc: 'Color in hexadecimal format'
        optional :initial, type: Boolean, desc: 'If the status is initial'
        optional :final, type: Boolean, desc: 'If the status is final'
        optional :active, type: Boolean, desc: 'If the status is active to use'
        optional :private, type: Boolean, desc: 'If the status is private or not'
      end
      put ':id' do
        validate_permission!(:edit, Reports::Category)

        status_params = {
          title: params[:title]
        }

        status_category_params = {
          initial: params[:initial],
          final: params[:final],
          active: params[:active],
          private: params[:private],
          color: params[:color]
        }

        status_params.each do |k, v|
          status_params.delete(k) if v.nil?
        end

        status_category_params.each do |k, v|
          status_category_params.delete(k) if v.nil?
        end

        category = load_category

        sc = category.status_categories.find_by(reports_status_id: safe_params[:id])

        if params[:title] && sc.status.title != params[:title]
          sc.destroy

          status = Reports::Status.find_or_create_by!(status_params)
          sc = category.status_categories.find_or_create_by(reports_status_id: status.id)
        else
          status = sc.status
        end

        status.update!(status_params)
        sc.update!(status_category_params)

        {
          status: Reports::Status::Entity.represent(category.reload.statuses, only: return_fields)
        }
      end

      desc 'Re-enable a status'
      put ':id/enable' do
        validate_permission!(:edit, Reports::Category)

        category = load_category
        status = Reports::Status.find(params[:id])

        sc = category.status_categories.find_by(reports_status_id: status.id)
        sc.update!(active: true)

        {
          status: Reports::Status::Entity.represent(status, only: return_fields)
        }
      end

      desc 'Delete a status (disables it)'
      delete ':id' do
        validate_permission!(:edit, Reports::Category)

        category = load_category
        status = Reports::Status.find(params[:id])
        sc = category.status_categories.find_by(reports_status_id: status.id)
        sc.update!(active: false)

        {
          status: Reports::Status::Entity.represent(status, only: return_fields)
        }
      end
    end
  end
end
