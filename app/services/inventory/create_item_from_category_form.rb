class Inventory::CreateItemFromCategoryForm
  attr_reader :category, :user, :item_params,
              :status

  def initialize(opts={})
    @category = opts[:category]
    @user = opts[:user]
    @item_params = opts[:data]
    @status = opts[:status]
  end

  def create!
    item = Inventory::Item.new(category: category, user: user, status: status)
    item.represented_data.attributes = item_params

    if item.represented_data.valid?
      item.represented_data.inject_to_data!
      item.save!
    else
      raise ActiveRecord::RecordInvalid.new(item.represented_data)
    end

    item
  end
end
