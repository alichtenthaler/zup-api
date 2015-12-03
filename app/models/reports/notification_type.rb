module Reports
  class NotificationType < Reports::Base
    belongs_to :category, class_name: 'Reports::Category',
                          foreign_key: 'reports_category_id'

    belongs_to :status, class_name: 'Reports::Status',
                        foreign_key: 'reports_status_id'

    validates :title, :category, presence: true
    validates :order, presence: true, if: :should_notifications_be_ordered?

    validate :status_belongs_to_category

    scope :active, -> { where(active: true) }
    scope :deactivated, -> { where(active: false) }
    scope :ordered, -> { order(order: :asc) }

    def self.for_category(category)
      where(reports_category_id: category.id)
    end

    def status_for_category
      status.for_category(category) if status
    end

    # Check if this notification was already sent for the item
    def sent_for_item?(item)
      Reports::Notification.last_notification_for(item, self).present?
    end

    def deactivated?
      !active?
    end

    def active!
      update!(active: true)
    end

    def deactivate!
      update!(active: false)
    end

    class Entity < Grape::Entity
      expose :id
      expose :category, using: Reports::Category::Entity
      expose :title
      expose :active
      expose :status_for_category, as: :status, using: Reports::StatusCategory::Entity
      expose :default_deadline_in_days
      expose :layout
      expose :created_at
      expose :updated_at
    end

    private

    def status_belongs_to_category
      if (category && status) && status.for_category(category).nil?
        errors.add(:status, I18n.t(:'errors.messages.invalid_belonging_to_category'))
      end
    end

    def should_notifications_be_ordered?
      category && category.ordered_notifications?
    end
  end
end
