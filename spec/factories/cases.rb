FactoryGirl.define do
  factory :case do
    association :created_by, factory: :user
    association :initial_flow, factory: :flow
  end
end
