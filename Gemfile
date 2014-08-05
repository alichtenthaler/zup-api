ruby '2.0.0'

source 'https://rubygems.org'

gem 'rails', '4.0.1'
gem 'pg'
gem 'rgeo', '0.3.20'
gem 'activerecord-postgis-adapter'
gem 'bcrypt-ruby', '~> 3.1.2'
gem 'grape', '~> 0.7.0'
gem 'grape-entity', '~> 0.4.2'
gem 'grape-swagger'
gem 'grape-swagger-rails', github: 'BrandyMint/grape-swagger-rails'
gem 'cancan'
gem 'sentry-raven', :git => 'https://github.com/getsentry/raven-ruby.git'
gem 'textacular', '~> 3.0', require: 'textacular/rails'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'armor'
gem 'carrierwave', :git => 'https://github.com/carrierwaveuploader/carrierwave.git'
gem 'fog', '~> 1.3.1'
gem 'rack-cors', :require => 'rack/cors'
gem 'squeel'
gem 'will_paginate'
gem 'api-pagination', '2.1.1'
gem 'mini_magick'
gem 'newrelic_rpm'
gem 'newrelic-grape'
gem 'settingslogic'
gem 'rack-perftools_profiler', :require => 'rack/perftools_profiler'
gem 'sidekiq'
# if you require 'sinatra' you get the DSL extended to Object
gem 'sinatra', '>= 1.3.0', :require => nil
gem 'yajl-ruby'
gem 'garner'
gem 'brcpfcnpj'
gem 'paper_trail'

group :production do
  gem 'rails_12factor'
  gem 'unicorn'
  gem 'sass-rails', '~> 4.0.0'
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '~> 4.0.0'
  gem 'jquery-rails'
  gem 'turbolinks'
  gem 'factory_girl_rails', require: false
  gem 'ffaker', require: false
  gem 'cpf_faker', require: false
end

group :development, :test do
  gem 'rspec-rails', '~> 3.0.0.beta'
  gem 'ffaker'
  gem 'cpf_faker'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'perftools.rb', require: false
  gem 'awesome_print'
  gem 'shoulda-matchers'
  gem 'pry', '0.9.12.2'
  gem 'pry-nav'
end

group :development do
  gem 'foreman'
end
