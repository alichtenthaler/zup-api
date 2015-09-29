module Reports
  class UpdateItemStatus
    attr_reader :item, :category, :user

    def initialize(item, user = nil)
      @item = item
      @category = item.category
      @user = user
    end

    def set_status(new_status)
      return false if new_status.id == item.status.try(:id)

      validate_status_belonging!(new_status)
      set_status_history_update(new_status)

      relation = get_status_relation(new_status)

      item.status = new_status
      item.resolved_at = Time.now if relation.final?
    end

    def update_status!(new_status)
      return false if new_status.id == item.status.try(:id)

      old_status = item.status
      set_status(new_status)

      item.save!

      Reports::CreateHistoryEntry.new(item, user)
        .create('status', "Foi alterado do status '#{old_status.title}' para '#{new_status.title}'",
                old: old_status.entity(only: [:id, :title]),
                new: new_status.entity(only: [:id, :title])
        )

      Reports::NotifyUser.new(item).notify_status_update!(new_status)
    end

    def create_comment!(message, visibility)
      comment = item.comments.create!(
        author: user,
        message: message,
        visibility: visibility
      )

      Reports::NotifyUser.new(item).notify_new_comment!(comment)
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
      unless get_status_relation(new_status)
        fail "Status doesn't belongs to category"
      end
    end

    def get_status_relation(status)
      category.status_categories.find_by(reports_status_id: status.id)
    end
  end
end
