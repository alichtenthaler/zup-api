ruby '2.2.1'

source 'https://rubygems.org'

gem 'rails', '4.1.9'
gem 'pg'
gem 'rgeo', '0.3.20'
gem 'rgeo-shapefile'
gem 'activerecord-postgis-adapter'
gem 'bcrypt', '~> 3.1.7'
gem 'grape', '~> 0.11.0'
gem 'grape-entity', github: 'intridea/grape-entity', ref: '48e5be7df9e362edc452332375e9397b12abdd45'
gem 'grape-swagger', '~> 0.7.2'
gem 'grape-swagger-rails', '~> 0.0.10', github: 'BrandyMint/grape-swagger-rails', ref: '121765deb29f1e2ab3e37c68ca7ff226c003eb13'
gem 'cancancan', '~> 1.10'
gem 'textacular', '~> 3.0', require: 'textacular/rails'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'armor'
gem 'carrierwave', '~> 0.9.0', git: 'https://github.com/carrierwaveuploader/carrierwave.git', ref: '17399e692d3b29ec7c2e609308c6e2ec7c622694'
gem 'fog', '~> 1.28.0'
gem 'rack-cors', require: 'rack/cors'
gem 'squeel'
gem 'will_paginate'
gem 'api-pagination'
gem 'mini_magick'
gem 'newrelic_rpm'
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
gem 'pr_geohash'
gem 'parallel', require: false
gem 'ruby-progressbar', require: false
gem 'sentry-raven', require: false
gem 'foreman'
gem 'minitest'
gem 'spring'

group :production do
  gem 'rails_12factor'
  gem 'unicorn', '~> 4.8.3'
  gem 'sass-rails', '~> 4.0.0'
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '~> 4.0.0'
  gem 'jquery-rails'
  gem 'turbolinks'
end

group :development, :test, :production do
  gem 'factory_girl_rails', '~> 4.3.0', require: false
  gem 'ffaker', require: false
  gem 'cpf_faker', require: false
end

group :development, :test do
  gem 'rspec-rails', '~> 3.2.1'
  gem 'awesome_print'
  gem 'pry-byebug', '1.3.3'
  gem 'pry-remote'
  gem 'dotenv-rails'
end

group :profile do
  gem 'ruby-prof'
end

group :development do
  gem 'foreman'
end

group :test do
  gem 'database_rewinder', github: 'ntxcode/database_rewinder', branch: 'filtering_interface'
  gem 'shoulda-matchers'
  gem 'knapsack'
  gem 'rubocop'
  gem 'rspec-nc', github: 'estevaoam/rspec-nc'
end
