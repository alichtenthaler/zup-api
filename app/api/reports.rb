module Reports
  class API < Base::API
    namespace :reports do
      mount Reports::Categories::API
      mount Reports::Items::API
      mount Reports::Stats::API
      mount Reports::Feedbacks::API
      mount Reports::Statuses::API
      mount Reports::Comments::API
      mount Reports::Notifications::API
      mount Reports::Webhooks::API
      mount Reports::ItemHistories::API
      mount Reports::OffensiveFlags::API
      mount Reports::NotificationTypes::API
      mount Reports::Perimeters::API
      mount Reports::CategoryPerimeters::API
    end
  end
end
