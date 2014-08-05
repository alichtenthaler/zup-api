# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :flow do
    title 'title test'
    description 'description test'
    created_by { User.first || create(:user) }
    resolution_states { [build(:resolution_state)] }
    steps { [build(:step)] }
    initial false
    status 'active'
  end

  factory :flow_without_relation, parent: :flow do
    resolution_states []
  end

  factory :flow_without_steps, parent: :flow do
    steps []
  end

  factory :flow_with_more_steps, parent: :flow do
    steps { [build(:step), build(:step)] }
  end
end
