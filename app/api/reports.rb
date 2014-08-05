module Reports
  class API < Grape::API
    namespace :reports do
      mount Reports::Categories::API
      mount Reports::Items::API
      mount Reports::Stats::API
      mount Reports::Feedbacks::API
      mount Reports::Statuses::API
    end
  end
end
