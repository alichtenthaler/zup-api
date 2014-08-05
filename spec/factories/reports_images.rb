FactoryGirl.define do
  factory :report_image, :class => 'Reports::Image' do
    image { fixture_file_upload(Rails.root.join('spec/fixtures/images/valid_report_category_icon.png')) }
  end
end