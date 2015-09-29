FactoryGirl.define do
  factory :inventory_formula_condition, class: 'Inventory::FormulaCondition' do
    association :formula, factory: :inventory_formula
    field { formula.category.fields.sample }
    operator 'equal_to'
    content 'test'
  end
end
