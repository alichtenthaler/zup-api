module Reports
  module Perimeters
    class API < Grape::API
      helpers do
        def load_perimeter(perimeter_id = params[:id])
          Reports::Perimeter.find(perimeter_id)
        end
      end

      namespace 'perimeters' do
        desc 'Create a new perimeter'
        params do
          requires :title, type: String,
            desc: 'The report perimeter title'
          requires :shp_file,
            desc: 'The .shp file, that stores the feature geometry (encoded on base64)'
          requires :shx_file,
            desc: 'The .shx file, that stores the index of the feature geometry (encoded on base64)'
          optional :solver_group_id, type: Integer,
            desc: 'The ID of the solver group'
      end
        post do
          authenticate!

          perimeter_params = safe_params.permit(:title, :solver_group_id)

          perimeter = Reports::Perimeter.new(perimeter_params)

          perimeter.shp_file = safe_params[:shp_file]
          perimeter.shx_file = safe_params[:shx_file]
          perimeter.save!

          {
            perimeter: Reports::Perimeter::Entity.represent(
              perimeter,
              only: return_fields
            )
          }
        end

        desc 'List all perimeters'
        paginate per_page: 25
        params do
          optional :paginate, type: Boolean,
            desc: 'Enable/Disable pagination for perimeters'
          optional :title, type: String,
            desc: 'Term to search perimeters by title'
          optional :sort, type: String,
            desc: 'The column that defines the order of perimeters, default is `created_at`'
          optional :order, type: String,
            desc: 'The order of perimeters will be returned, can be ascending (asc) or descending (desc)'
        end
        get do
          authenticate!

          perimeters = SearchPerimeters.new(
            title: params[:title],
            sort: params[:sort],
            order: params[:order],
            paginate: params[:paginate],
            paginator: method(:paginate)
          )

          perimeters = perimeters.search

          {
            perimeters: Reports::Perimeter::Entity.represent(
              perimeters,
              only: return_fields
            )
          }
        end

        desc "Shows perimeter's info"
        get ':id' do
          authenticate!

          perimeter = load_perimeter

          {
            perimeter: Reports::Perimeter::Entity.represent(
              perimeter,
              only: return_fields
            )
          }
        end

        desc 'Update perimeter'
        params do
          requires :title, type: String,
            desc: 'The report perimeter title'
          optional :solver_group_id, type: Integer,
            desc: 'The ID of the solver group'
        end
        put ':id' do
          authenticate!

          perimeter_params = safe_params.permit(:title, :solver_group_id)

          perimeter = load_perimeter
          perimeter.update!(perimeter_params)

          {
            perimeter: Reports::Perimeter::Entity.represent(
              perimeter,
              only: return_fields
            )
          }
        end

        desc 'Destroy perimeter'
        delete ':id' do
          authenticate!

          perimeter = load_perimeter

          if perimeter.destroy
            status 204
          else
            status 422
          end
        end
      end
    end
  end
end
