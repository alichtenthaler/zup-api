# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :inventory_formula_history, class: 'Inventory::FormulaHistory' do
    association :formula, factory: :inventory_formula
    association :item, factory: :inventory_item
  end
end
