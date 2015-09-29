module BusinessReports
  class API < Base::API
    mount BusinessReports::Charts::API

    helpers do
      def load_business_report(id = nil)
        BusinessReport.find(id || params[:id])
      end
    end

    namespace :business_reports do
      desc 'List all business reports'
      get do
        authenticate!
        validate_permission!(:view, BusinessReport)

        business_reports = BusinessReport.all

        unless user_permissions.can?(:manage, BusinessReport)
          business_reports = business_reports.where(id: user_permissions.business_reports_visible)
        end

        present business_reports, using: BusinessReport::Entity, only: return_fields
      end

      desc 'Shows a business report'
      get ':id' do
        authenticate!
        business_report = load_business_report
        validate_permission!(:view, business_report)

        present business_report, using: BusinessReport::Entity, only: return_fields
      end

      desc 'Shows a business report as XLS'
      get ':id/export/xls' do
        authenticate!
        business_report = load_business_report
        validate_permission!(:view, business_report)

        package = BusinessReports::ExportBusinessReportToXls.new(business_report).export

        begin
          filename = "#{business_report.title.gsub(" ", "_")}.xls"

          temp = Tempfile.new(filename)
          package.serialize(temp.path)

          env['api.format'] = :binary
          header 'Content-Disposition', "attachment; filename*=UTF-8''#{URI.escape("#{business_report.title}.xls")}"

          temp.read
        ensure
          temp.close
          temp.unlink
        end
      end

      desc 'Create a business report'
      params do
        requires :title, type: String
        optional :summary, type: String
        optional :begin_date, type: Date
        optional :end_date, type: Date
      end
      post do
        authenticate!
        validate_permission!(:create, BusinessReport)

        business_reports_params = safe_params.permit(
          :title, :summary, :begin_date, :end_date
        )

        business_reports_params[:user] = current_user

        business_report = BusinessReport.create!(business_reports_params)
        present business_report, using: BusinessReport::Entity, only: return_fields
      end

      desc 'Updates a business report'
      params do
        optional :title, type: String
        optional :summary, type: String
        optional :begin_date, type: Date
        optional :end_date, type: Date
      end
      put ':id' do
        authenticate!
        business_report = load_business_report
        validate_permission!(:edit, business_report)

        business_reports_params = safe_params.permit(
          :title, :summary, :begin_date, :end_date
        )

        business_report.update!(business_reports_params)
        present business_report, using: BusinessReport::Entity, only: return_fields
      end

      desc 'Delete a business report'
      delete ':id' do
        authenticate!
        business_report = load_business_report
        validate_permission!(:delete, business_report)

        business_report.destroy!

        {
          message: I18n.t(:'business_reports.delete.success')
        }
      end
    end
  end
end
