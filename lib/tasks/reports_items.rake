namespace :reports do
  task set_overdue: :environment do
    SetReportsOverdue.new.perform
  end
end
