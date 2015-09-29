# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :case do
    created_by { User.first || create(:user) }
    initial_flow_id 1
  end
end
