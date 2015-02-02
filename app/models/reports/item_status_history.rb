class Reports::ItemStatusHistory < Reports::Base
  belongs_to :item, class_name: 'Reports::Item', foreign_key: 'reports_item_id'
  belongs_to :previous_status, class_name: 'Reports::Status', foreign_key: 'previous_status_id'
  belongs_to :new_status, class_name: 'Reports::Status', foreign_key: 'new_status_id'

  validates :item, presence: true
  validates :new_status, presence: true

  default_scope order('id ASC')
  scope :public, -> { joins(:new_status).where(new_status: { private: false }) }

  class Entity < Grape::Entity
    expose :id
    expose :previous_status, using: Reports::Status::Entity
    expose :new_status, using: Reports::Status::Entity
    expose :created_at
    expose :updated_at
  end
end
