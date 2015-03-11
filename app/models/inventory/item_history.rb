class Inventory::ItemHistory < Inventory::Base
  include ArrayRelate

  belongs_to :item, class_name: 'Inventory::Item', foreign_key: 'inventory_item_id'
  belongs_to :user

  validates :kind, presence: true
  validates :action, presence: true
  validates :user, presence: true
  validates :item, presence: true

  array_belongs_to :objects, polymorphic: 'object_type'

  class Entity < Grape::Entity
    expose :id
    expose :inventory_item_id
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
