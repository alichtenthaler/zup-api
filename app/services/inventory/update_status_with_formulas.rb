class Inventory::UpdateStatusWithFormulas
  attr_reader :item, :formulas

  def initialize(item)
    @item = item
  end

  # Updates an item status
  def check_and_update!
    @formulas ||= retrieve_formulas

    formulas.each do |formula|
      validator = Inventory::FormulaValidator.new(item, formula)

      if validator.valid?
        item.update(status: formula.status)

        alert = formula.alerts.create(groups_alerted: formula.groups_to_alert)
        formula.histories.create(item: item, alert: alert)
      end
    end
  end

  private

  def retrieve_formulas
    if item && item.category
      item.category.formulas
    end
  end
end
