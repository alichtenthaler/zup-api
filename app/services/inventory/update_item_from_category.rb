class Inventory::UpdateItemFromCategory
  attr_reader :item, :item_params

  def initialize(item, item_params)
    @item = item
    @item_params = item_params
  end

  def update!
    item.represented_data.attributes = item_params

    if item.represented_data.valid?
      item.represented_data.inject_to_data!
      item.save!

      check_formulas
    else
      raise ActiveRecord::RecordInvalid.new(item.represented_data)
    end

    item
  end

  private

  def check_formulas
    updater = Inventory::UpdateStatusWithFormulas.new(item)
    updater.check_and_update!
  end
end
