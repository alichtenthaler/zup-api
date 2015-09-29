# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

ENV['DISABLE_MEMORY_CACHE'] = 'true'

require File.expand_path('../application', __FILE__)

task :environment do
end

Application.load_tasks
Knapsack.load_tasks if defined?(Knapsack)

Rake.load_rakefile 'active_record/railties/databases.rake'
