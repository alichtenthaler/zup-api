module Reports
  class UpdateItemStatus
    attr_reader :item, :category, :user

    def initialize(item, user = nil)
      @item = item
      @category = item.category
      @user = user
    end

    def set_status(new_status)
      validate_status_belonging!(new_status)
      set_status_history_update(new_status)

      item.status = new_status
    end

    def update_status!(new_status)
      set_status(new_status)

      item.save!
      Reports::CreateHistoryEntry.new(item, user)
                                 .create('status', 'Status foi alterado', new_status)

      Reports::NotifyUser.new(item).notify_status_update!(new_status)
    end

    def create_comment!(message, visibility)
      item.comments.create!(
        author: user,
        message: message,
        visibility: visibility
      )
    end

    private

    def set_status_history_update(new_status)
      if new_status.id != item.status.try(:id)
        item.status_history.build(
          previous_status: item.status,
          new_status: new_status
        )
      end
    end

    def validate_status_belonging!(new_status)
      unless category.status_categories.exists?(reports_status_id: new_status.id)
        fail "Status doesn't belongs to category"
      end
    end
  end
end
