FactoryGirl.define do
  factory :flow do
    title 'title test'
    description 'description test'
    created_by { User.first || create(:user) }
    user { User.first }
    resolution_states { [build(:resolution_state, default: true)] }
    steps { [build(:step)] }
    initial false
    status 'active'
  end

  factory :flow_without_relation, parent: :flow do
    resolution_states []
    resolution_states_versions { {} }
  end

  factory :flow_without_steps, parent: :flow do
    steps []
    steps_versions { {} }
  end

  factory :flow_with_more_steps, parent: :flow do
    steps { [build(:step), build(:step)] }
  end
end
