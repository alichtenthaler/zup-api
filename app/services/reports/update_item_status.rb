module Reports
  class UpdateItemStatus
    attr_reader :item, :category

    def initialize(item)
      @item = item
      @category = item.category
    end

    def set_status(new_status)
      validate_status_belonging!(new_status)
      set_status_history_update(new_status)

      item.status = new_status
    end

    def update_status!(new_status)
      set_status(new_status)

      item.save!

      permissions = UserAbility.new(item.user)

      if item.status_history.count > 1 &&
        (permissions.can?(:manage, Reports::Item) || !new_status.private_for_category?(category))
        UserMailer.delay.notify_report_status_update(item)
      end
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
