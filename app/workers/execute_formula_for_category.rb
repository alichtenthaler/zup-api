class ExecuteFormulaForCategory
  include Sidekiq::Worker

  def perform(user_id, formula_id)
    user = User.find_by(id: user_id)
    formula = Inventory::Formula.find_by(id: formula_id)

    if user && formula
      # Get all inventory items and check the formula against it
      formula.category.items.each do |item|
        service = Inventory::UpdateStatusWithFormulas.new(item, user, [formula])
        service.check_and_update!
      end
    end
  end
end
