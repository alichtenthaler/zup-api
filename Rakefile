# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

ENV['DISABLE_MEMORY_CACHE'] = 'true'

require File.expand_path('../application', __FILE__)

task :environment do
end

task :eager_load do
  Application.eager_load!
end

Application.load_tasks
Knapsack.load_tasks if defined?(Knapsack)

load 'pg_search/tasks.rb'

Rake.load_rakefile 'active_record/railties/databases.rake'

if ActiveRecord::Base.schema_format == :sql
  Rake::Task['db:seed'].enhance(['environment', 'eager_load'])
  Rake::Task['db:migrate'].enhance(['environment', 'eager_load'])
  Rake::Task['db:create'].enhance(['environment'])

  Rake::Task['db:schema:load'].clear.enhance(['environment']) do
    Rake::Task['db:structure:load'].invoke
  end
end
