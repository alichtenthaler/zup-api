# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reports_feedback_image, :class => 'Reports::FeedbackImage' do
    reports_feedback nil
    image "MyString"
  end
end
