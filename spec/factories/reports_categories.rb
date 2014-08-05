include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :reports_category, :class => 'Reports::Category' do
    sequence :title do |n|
      "The #{n}th report category"
    end

    user_response_time 1 * 60 * 60 * 24
    resolution_time 2 * 60 * 60 * 24
    active true
    allows_arbitrary_position false
    color '#f3f3f3'
    icon { Rails.root.join('spec/fixtures/images/valid_report_category_icon.png').open }
    marker { Rails.root.join('spec/fixtures/images/valid_report_category_marker.png').open }

    factory :reports_category_with_statuses do
      after(:create) do |reports_category, _|
        reports_category.update_statuses!([
          build(:status, title: 'Em andamento').as_json,
          build(:initial_status).as_json,
          build(:final_status).as_json,
          build(:final_status, title: "Não resolvidas", color: "#999999").as_json
        ])
      end
    end
  end
end
