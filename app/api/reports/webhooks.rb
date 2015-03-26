module Reports::Webhooks
  class API < Grape::API
    namespace :webhooks do
      desc 'Receives a new report'
      params do
        requires :external_category_id, type: Integer
        requires :is_solicitation, type: Boolean
        requires :is_report, type: Boolean
        optional :latitude, type: Float
        optional :longitude, type: Float
        optional :description, type: String
        optional :address, type: String
        optional :reference, type: String
        optional :images, type: Array
        optional :status, type: Hash
        optional :user, type: Hash
        optional :comments, type: Array
      end
      post do
        service = Reports::CreateItemFromWebhook.new(params)
        report = service.create!

        {
          message: 'Relato criado com sucesso',
          uuid: report.uuid
        }
      end

      desc 'Updates a reports status'
      params do
        optional :status, type: Hash
        optional :comments, type: Array
      end
      put ':uuid' do
        uuid = params[:uuid]

        report = Reports::Item.find_by!(uuid: uuid)

        service = Reports::UpdateItemFromWebhook.new(report, params)
        service.update!

        {
          message: 'Relato atualizado com sucesso'
        }
      end
    end
  end
end
