# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reports_comment, class: 'Reports::Comment' do
    association :item, factory: :reports_item
    association :author, factory: :user
    visibility { Reports::Comment::PUBLIC }
    message "This is a test comment"
  end
end
