module Reports
  class Perimeter < Reports::Base
    include EncodedFileUploadable
    include LikeSearchable

    belongs_to :group,
      foreign_key: 'solver_group_id'

    has_many :category_perimeters,
      class_name: 'Reports::CategoryPerimeter',
      foreign_key: 'reports_perimeter_id',
      dependent: :delete_all

    default_scope { order(created_at: :asc) }

    scope :search, ->(latitude, longitude) do
      imported
      .where("ST_Contains(geometry, ST_GeomFromText('POINT(? ?)', 4326))", longitude.to_f, latitude.to_f)
    end

    validates :title, :shp_file, :shx_file, presence: true

    after_commit :import_shapefile

    enum status: [
      :pendent,
      :imported,
      :invalid_file,
      :invalid_quantity,
      :invalid_geometry,
      :unknown_error
    ]

    mount_uploader :shp_file, ShapefileUploader
    mount_uploader :shx_file, ShapefileUploader

    accepts_encoded_file :shp_file, :shx_file

    class Entity < Grape::Entity
      expose :id
      expose :title
      expose :status
      expose :created_at
      expose :updated_at
      expose :group
    end

    private

    def import_shapefile
      if pendent?
        ImportShapefile.perform_in(1.minutes, id)
      end
    end
  end
end
