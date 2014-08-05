# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trigger do
    title { generate(:name) }
    trigger_conditions { [build(:trigger_condition)] }
    action_type 'disable_steps'
    action_values [2]
    order_number 1
    description { "description #{generate(:name)}" }
    step nil
  end
end
