class Inventory::FormulaAlert < Inventory::Base
  LEVELS = {
    (NOTIFICATION = 0) => "Notificação",
    (CRITICAL = 1) => "Crítico"
  }

  belongs_to :formula, class_name: "Inventory::Formula", foreign_key: "inventory_formula_id"
  has_many :formula_histories, class_name: "Inventory::FormulaHistory", foreign_key: 'inventory_formula_alert_id'

  validates :formula, presence: true

  def affected_items
    self.formula_histories.includes(:item).map(&:item)
  end

  def sent?
    !self.sent_at.nil?
  end

  def level_name
    LEVELS[self.level]
  end

  class Entity < Grape::Entity
    expose :id
    expose :formula
    expose :groups_alerted
    expose :affected_items, using: Inventory::Item::Entity
  end
end
