# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :field do
    title { generate(:name) }
    field_type "integer"
    category_inventory_id 1
    category_report_id 1
    origin_field_id 1
    active true
    step nil
  end
end
