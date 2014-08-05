# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :resolution_state do
    title { generate(:name) }
    default false
    active true
  end
end
