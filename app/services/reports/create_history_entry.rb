module Reports
  class CreateHistoryEntry
    attr_reader :item, :user, :kind, :action, :objects

    def initialize(item, user = nil)
      @item = item
      @user = user
    end

    def create(kind, action, objects)
      entry = build_object(kind, action, objects)
      entry.save!
    rescue ActiveRecord::RecordInvalid => e
      Raven.capture_exception(e)
    end

    private

    def build_object(kind, action, objects)
      Reports::ItemHistory.new(
        item: item,
        user: user,
        kind: kind,
        action: action,
        objects: objects
      )
    end
  end
end
