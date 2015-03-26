class Inventory::CreateItemFromCategoryForm
  attr_reader :category, :user, :item_params,
              :status

  def initialize(opts = {})
    @category = opts[:category]
    @user = opts[:user]
    @item_params = opts[:data]
    @status = opts[:status]
  end

  def create!
    item = Inventory::Item.new(category: category, user: user, status: status)
    representer = item.represented_data(user)
    representer.attributes = item_params

    if representer.valid?
      representer.inject_to_data!
      representer.item.save!
    else
      fail ActiveRecord::RecordInvalid.new(representer)
    end

    item
  end
end
