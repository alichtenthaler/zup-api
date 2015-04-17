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
      if item.update(category: new_category)
        Reports::UpdateItemStatus.new(item).update_status!(new_status)
        Reports::CreateHistoryEntry.new(item, user)
          .create('category', "O relato foi movido para a categoria '#{new_category.title}'", new_category)
      end
    end
  end
end
