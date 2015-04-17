class Reports::ItemHistory < Reports::Base
  include ArrayRelate

  KINDS = %w(address description status category forward user_assign overdue)

  belongs_to :item, class_name: 'Reports::Item', foreign_key: 'reports_item_id'
  belongs_to :user

  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :action, presence: true
  validates :item, presence: true

  array_belongs_to :objects, polymorphic: 'object_type'

  class Entity < Grape::Entity
    expose :id
    expose :reports_item_id
    expose :user, using: User::Entity
    expose :kind
    expose :action
    expose :objects
    expose :created_at

    def objects
      if object.objects.any?
        object.object_entity_class.represent(object.objects)
      else
        []
      end
    end
  end
end
