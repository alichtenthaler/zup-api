class Reports::Image < Reports::Base
  belongs_to :item, foreign_key: 'reports_item_id'

  mount_uploader :image, ImageUploader

  def url
    image.url
  end

  class Entity < Grape::Entity
    expose :url
  end
end
