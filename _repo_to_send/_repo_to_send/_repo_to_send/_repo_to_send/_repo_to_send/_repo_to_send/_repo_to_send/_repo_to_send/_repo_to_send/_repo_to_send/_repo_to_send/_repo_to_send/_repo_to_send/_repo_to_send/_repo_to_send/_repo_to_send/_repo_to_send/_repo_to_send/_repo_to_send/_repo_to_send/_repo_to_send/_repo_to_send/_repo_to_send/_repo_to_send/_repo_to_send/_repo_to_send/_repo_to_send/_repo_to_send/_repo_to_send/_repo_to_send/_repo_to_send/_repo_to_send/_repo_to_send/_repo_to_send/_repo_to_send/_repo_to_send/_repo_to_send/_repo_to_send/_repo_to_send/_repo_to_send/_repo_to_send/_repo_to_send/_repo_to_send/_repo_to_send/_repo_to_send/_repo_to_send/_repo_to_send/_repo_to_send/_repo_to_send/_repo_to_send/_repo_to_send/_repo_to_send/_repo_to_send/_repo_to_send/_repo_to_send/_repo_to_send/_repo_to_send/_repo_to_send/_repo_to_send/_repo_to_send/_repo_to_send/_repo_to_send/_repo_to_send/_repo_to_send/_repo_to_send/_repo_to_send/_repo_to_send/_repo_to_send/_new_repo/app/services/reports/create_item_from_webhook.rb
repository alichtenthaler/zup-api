module Reports
  class CreateItemFromWebhook
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def create!
      ActiveRecord::Base.transaction do
        report = Reports::Item.create!(build_reports_params)
        report.update_images!(build_images_params(params[:images]))

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

      # Find or create status
      status = find_or_create_status!(params[:status], category)
      reports_params = reports_params.merge(
        reports_status_id: status.id
      )

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
        ignore_password_requirement: true,
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
      status = Reports::Status.create_with(color: '#cccccc')
                              .find_or_create_by!(title: name)

      category.status_categories.find_or_create_by!(
        reports_status_id: status.id
      )

      status
    end

    def find_category(external_category_id)
      Webhook.zup_category(external_category_id)
    end
  end
end
