ruby '2.2.1'

source 'https://rubygems.org'

gem 'activerecord', '4.1.10'
gem 'activesupport', '4.1.10'
gem 'actionmailer', '4.1.10'
gem 'actionpack', '4.1.10'
gem 'pg'
gem 'rgeo', '0.3.20'
gem 'rgeo-shapefile'
gem 'activerecord-postgis-adapter'
gem 'bcrypt', '~> 3.1.7'
gem 'grape', '~> 0.11.0'
gem 'grape-entity', github: 'intridea/grape-entity', ref: '48e5be7df9e362edc452332375e9397b12abdd45'
gem 'grape-swagger'
gem 'cancancan', '~> 1.10'
gem 'textacular', '~> 3.0'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'armor'
gem 'carrierwave', '~> 0.9.0', git: 'https://github.com/carrierwaveuploader/carrierwave.git', ref: '17399e692d3b29ec7c2e609308c6e2ec7c622694'
gem 'fog', '~> 1.28.0'
gem 'rack-cors', require: 'rack/cors'
gem 'squeel'
gem 'will_paginate', require: false
gem 'api-pagination', require: false
gem 'mini_magick'
gem 'settingslogic'
gem 'sidekiq'
gem 'sidekiq-cron'
gem 'sinatra', '>= 1.3.0', require: nil
gem 'oj'
gem 'oj_mimic_json'
gem 'garner'
gem 'brcpfcnpj'
gem 'paper_trail', '~> 4.0.0.beta2'
gem 'pushmeup', github: 'alarionov/pushmeup', ref: 'fd43ba21ef3bbe8053f8878f9f800f7185b98156'
gem 'atomic_arrays'
gem 'parallel', require: false
gem 'ruby-progressbar', require: false
gem 'sentry-raven', require: false
gem 'foreman', require: false
gem 'minitest'
gem 'dotenv'
gem 'appsignal'
gem 'grape-appsignal', github: 'madglory/grape-appsignal'
gem 'grape_logging'
gem 'require_all'
gem 'redis-activesupport'
gem 'redlock'
gem 'geocoder'

group :development, :test, :production do
  gem 'factory_girl', '~> 4.3.0', require: false
  gem 'ffaker', require: false
  gem 'cpf_faker', require: false
end

group :development, :test do
  gem 'rspec', '~> 3.2.0'
  gem 'awesome_print'
  gem 'pry-byebug', '1.3.3'
  gem 'pry-remote'
end

group :profile do
  gem 'stackprof'
end

group :development do
  gem 'foreman'
  gem 'thin'
  gem 'passenger'
end

group :test do
  gem 'database_rewinder', github: 'ntxcode/database_rewinder', branch: 'filtering_interface'
  gem 'shoulda-matchers'
  gem 'knapsack'
  gem 'rubocop'
  gem 'rspec-nc', github: 'estevaoam/rspec-nc'
end
