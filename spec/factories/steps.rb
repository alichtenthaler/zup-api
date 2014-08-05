# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :step do
    title { generate(:name) }
    description 'MyText'
    step_type 'flow'
    sequence(:order_number) { |n| n }
  end

  factory :step_type_form, parent: :step do
    step_type 'form'
    fields { [build(:field)] }
  end

  factory :step_type_form_without_fields, parent: :step_type_form do
    fields []
  end
end
