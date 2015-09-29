class Inventory::CreateItemFromCategoryForm
  attr_reader :category, :user, :item_params,
              :status, :item

  def initialize(opts = {})
    @category = opts[:category]
    @user = opts[:user]
    @item_params = opts[:data]
    @status = opts[:status]
  end

  def create!
    @item = Inventory::Item.new(category: category, user: user, status: status)
    representer = item.represented_data(user)
    representer.attributes = item_params

    if representer.valid?
      representer.inject_to_data!
      representer.item.save!

      representer.create_history_entry

      check_formulas
    else
      fail ActiveRecord::RecordInvalid.new(representer)
    end

    item
  end

  private

  def check_formulas
    updater = Inventory::UpdateStatusWithFormulas.new(item, user)
    updater.check_and_update!
  end
end
