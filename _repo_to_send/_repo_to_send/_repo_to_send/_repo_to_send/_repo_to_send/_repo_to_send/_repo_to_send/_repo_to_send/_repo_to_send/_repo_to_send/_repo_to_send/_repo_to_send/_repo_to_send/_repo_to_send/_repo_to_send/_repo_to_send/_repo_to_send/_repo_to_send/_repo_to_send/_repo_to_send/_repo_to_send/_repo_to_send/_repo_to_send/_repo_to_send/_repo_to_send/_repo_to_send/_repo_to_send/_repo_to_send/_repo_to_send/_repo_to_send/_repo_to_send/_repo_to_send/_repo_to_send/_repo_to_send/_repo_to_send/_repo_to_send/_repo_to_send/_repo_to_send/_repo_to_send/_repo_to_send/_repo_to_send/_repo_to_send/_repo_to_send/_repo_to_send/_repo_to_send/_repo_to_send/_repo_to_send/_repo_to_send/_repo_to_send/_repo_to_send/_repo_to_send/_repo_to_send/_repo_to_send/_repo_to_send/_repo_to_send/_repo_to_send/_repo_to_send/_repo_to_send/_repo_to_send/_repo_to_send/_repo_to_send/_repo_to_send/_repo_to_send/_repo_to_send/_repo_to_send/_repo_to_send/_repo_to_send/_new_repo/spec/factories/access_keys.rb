# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:random_key) { SecureRandom.hex }

  factory :access_key do
    user
    key { generate(:random_key) }
    expired false
    expired_at nil

    factory :expired_access_key do
      expired true
      expired_at { 1.day.ago }
    end
  end
end
