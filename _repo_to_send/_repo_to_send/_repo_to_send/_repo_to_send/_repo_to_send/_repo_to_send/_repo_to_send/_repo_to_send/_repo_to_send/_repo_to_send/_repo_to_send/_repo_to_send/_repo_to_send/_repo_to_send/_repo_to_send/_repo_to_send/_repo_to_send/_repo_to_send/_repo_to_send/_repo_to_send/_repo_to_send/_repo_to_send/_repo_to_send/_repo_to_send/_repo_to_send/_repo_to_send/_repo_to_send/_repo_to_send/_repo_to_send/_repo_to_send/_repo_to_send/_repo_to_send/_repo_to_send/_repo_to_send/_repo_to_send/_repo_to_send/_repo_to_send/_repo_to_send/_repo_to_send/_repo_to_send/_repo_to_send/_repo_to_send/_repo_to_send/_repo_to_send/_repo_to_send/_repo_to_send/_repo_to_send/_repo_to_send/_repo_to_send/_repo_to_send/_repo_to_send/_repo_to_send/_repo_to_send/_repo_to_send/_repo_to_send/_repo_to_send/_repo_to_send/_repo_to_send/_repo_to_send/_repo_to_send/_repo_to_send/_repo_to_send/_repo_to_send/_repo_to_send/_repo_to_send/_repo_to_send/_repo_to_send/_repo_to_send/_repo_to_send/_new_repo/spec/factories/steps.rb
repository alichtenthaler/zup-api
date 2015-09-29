FactoryGirl.define do
  factory :step do
    title { generate(:name) }
    description 'MyText'
    step_type 'flow'
    user { User.first }
  end

  factory :step_type_form, parent: :step do
    step_type 'form'
    fields { [build(:field)] }
  end

  factory :step_type_form_without_fields, parent: :step_type_form do
    fields []
  end
end
