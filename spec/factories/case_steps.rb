# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :case_step do
    created_by { User.first || create(:user) }
    step       { Step.first || create(:step) }
    step_version 1
    data { {"#{Field.first.id}" => 'xx'} }
  end
end
