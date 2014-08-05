# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trigger_condition do
    field { Field.last || build(:field) }
    condition_type "=="
    values [1]
    trigger nil
  end
end
