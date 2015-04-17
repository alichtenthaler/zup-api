module Reports
  class UpdateItemFromWebhook < CreateItemFromWebhook
    attr_reader :report, :params

    def initialize(report, params)
      @report = report
      @params = params
    end

    def update!
      ActiveRecord::Base.transaction do
        report.update!(build_reports_params)

        report.reload

        if params[:external_category_id]
          category = find_category(params[:external_category_id])
        end

        if params[:status]
          status = find_or_create_status!(params[:status], category || report.category)
        end

        if status && category
          Reports::ChangeItemCategory.new(report, category, status).process!
        elsif status
          Reports::UpdateItemStatus.new(report).update_status!(status)
        end

        report
      end
    end

    private

    def build_reports_params
      reports_params = {}

      # Comments params
      comments = params[:comments]

      if comments
        comments.each do |comment|
          reports_params = reports_params.deep_merge(
            comments_attributes: [{
              author: create_user(comment[:user]),
              message: comment[:message]
            }]
          )
        end
      end

      reports_params
    end
  end
end
