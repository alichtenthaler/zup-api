module Reports
  class ChangeItemCategory
    attr_reader :item, :new_category, :new_status, :user

    def initialize(item, new_category, new_status, user = nil)
      @item = item
      @new_category = new_category
      @new_status = new_status
      @user = user
    end

    def process!
      old_category = item.category

      if old_category.id != new_category.id && item.update(category: new_category)
        update_status!

        # Forward to default group
        if new_category.default_solver_group
          Reports::ForwardToGroup.new(item, user).forward_without_comment!(
            new_category.default_solver_group
          )
        else
          item.update(assigned_group: nil)
        end

        Reports::CreateHistoryEntry.new(item, user)
          .create('category', "O relato foi movido da categoria '#{old_category.title}' para '#{new_category.title}'",
                  old: old_category.entity(only: [:id, :title]),
                  new: new_category.entity(only: [:id, :title]))
      elsif old_category.id == new_category.id
        update_status!
      end
    end

    private

    def update_status!
      Reports::UpdateItemStatus.new(item).update_status!(new_status)
    end
  end
end
