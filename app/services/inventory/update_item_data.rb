class Inventory::UpdateItemData
  attr_reader :item, :item_params, :user

  def initialize(item, item_params, user)
    @item = item
    @item_params = item_params
    @user = user
  end

  def update!
    item_representer = item.represented_data(user)
    item_representer.attributes = item_params

    if item_representer.valid?
      item_representer.inject_to_data!
      item_representer.save!

      item_representer.create_history_entry

      check_formulas
    else
      fail ActiveRecord::RecordInvalid.new(item.represented_data)
    end

    item
  end

  private

  def check_formulas
    updater = Inventory::UpdateStatusWithFormulas.new(item, user)
    updater.check_and_update!
  end
end
