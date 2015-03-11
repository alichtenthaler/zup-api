FactoryGirl.define do
  factory :resolution_state do
    title { generate(:name) }
    default false
    active true
    user { User.first }
  end
end
