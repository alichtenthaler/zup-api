class ExecuteFormulaForItems
  include Sidekiq::Worker

  sidekiq_options queue: :low

  def perform(user_id, formula_id, items_ids)
    user = User.find_by(id: user_id)
    formula = Inventory::Formula.find_by(id: formula_id)
    items = Inventory::Item.where(id: items_ids)

    if user && formula && items
      Inventory::Item.transaction do
        items.each do |item|
          begin
            service = Inventory::UpdateStatusWithFormulas.new(item, user, [formula])
            service.check_and_update!
          rescue => e
            Raven.capture_exception(e)
          end
        end
      end
    end
  end
end
