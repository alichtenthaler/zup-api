# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:flag_name) { |n| "flag_#{n}" }

  factory :feature_flag do
    name { generate(:flag_name) }
    status 1

    trait :disabled do
      status 0
    end
  end
end
