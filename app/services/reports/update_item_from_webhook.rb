module Reports
  class UpdateItemFromWebhook
    attr_reader :report, :params

    def initialize(report, params)
      @report = report
      @params = params
    end

    def update!
      ActiveRecord::Base.transaction do
        report.update!(build_reports_params)

        if params[:images]
          report.update_images!(build_images_params(params[:images]))
        end

        if params[:status]
          status = find_or_create_status!(params[:status], report.category)
          Reports::UpdateItemStatus.new(report).set_status(status)
        end

        report
      end
    end

    private

    def build_reports_params
      reports_params = {}

      category = find_category(params[:external_category_id])

      # Report params
      reports_params = reports_params.merge(
        external_category_id: params[:external_category_id],
        category: category,
        is_solicitation: params[:is_solicitation],
        is_report: params[:is_report],
        description: params[:description],
        address: params[:address],
        reference: params[:reference],
        user: create_user(params[:user])
      )

      if params[:longitude] && params[:latitude]
        reports_params = reports_params.merge(
          position: Reports::Item.rgeo_factory.point(params[:longitude], params[:latitude])
        )
      end

      # Comments params
      comments = params[:comments]
      comments.each do |comment|
        reports_params = reports_params.deep_merge(
          comments_attributes: [{
            author: create_user(comment[:user]),
            message: comment[:message]
          }]
        )
      end

      reports_params
    end

    def create_user(parameters)
      user = parameters

      user_params = {
        name: user[:name],
        email: user[:email],
        phone: user[:phone],
        document: user[:document],
        address: user[:address],
        address_additional: user[:address_additional],
        postal_code: user[:postal_code],
        district: user[:district],
        from_webhook: true
      }

      user_email = user_params.delete(:email)

      User.create_with(user_params)
          .find_or_create_by!(email: user_email)
    end

    def build_images_params(parameters)
      images = []

      parameters.each do |param|
        images << {
          'content' => param[:data]
        }
      end

      images
    end

    def find_or_create_status!(parameters, category)
      name = parameters[:name]
      status = Reports::Status.find_or_create_by(title: name)

      category.status_categories.create(
        status: status
      )

      status
    end

    def find_category(external_category_id)
      Reports::Category.first
    end
  end
end
