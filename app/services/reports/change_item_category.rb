module Reports
  class ChangeItemCategory
    attr_reader :item, :new_category, :new_status, :user

    def initialize(item, new_category, new_status, user)
      @item = item
      @new_category = new_category
      @new_status = new_status
      @user = user
    end

    def process!
      if item.update(category: new_category)
        Reports::UpdateItemStatus.new(item).update_status!(new_status)
      end
    end
  end
end
