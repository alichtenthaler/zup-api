ruby '2.0.0'

source 'https://rubygems.org'

gem 'dotenv-rails', groups: [:development, :test]
gem 'rails', '4.0.1'
gem 'pg'
gem 'rgeo', '0.3.20'
gem 'activerecord-postgis-adapter'
gem 'bcrypt-ruby', '~> 3.1.2'
gem 'grape', '~> 0.7.0'
gem 'grape-entity', '~> 0.4.2'
gem 'grape-swagger', '~> 0.7.2'
gem 'grape-swagger-rails', '~> 0.0.10', github: 'BrandyMint/grape-swagger-rails', ref: '121765deb29f1e2ab3e37c68ca7ff226c003eb13'
gem 'cancan'
gem 'sentry-raven', :git => 'https://github.com/getsentry/raven-ruby.git', ref: '3563a6b08bfde1d1b603b40cc092c0a75a2ab032'
gem 'textacular', '~> 3.0', require: 'textacular/rails'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'armor'
gem 'carrierwave', '~> 0.9.0', git: 'https://github.com/carrierwaveuploader/carrierwave.git', ref: '17399e692d3b29ec7c2e609308c6e2ec7c622694'
gem 'fog', '~> 1.3.1'
gem 'rack-cors', :require => 'rack/cors'
gem 'squeel'
gem 'will_paginate'
gem 'api-pagination', '2.1.1'
gem 'mini_magick'
gem 'newrelic_rpm'
gem 'newrelic-grape'
gem 'settingslogic'
gem 'sidekiq'
gem 'sidekiq-cron'
gem 'sinatra', '>= 1.3.0', :require => nil
gem 'yajl-ruby'
gem 'garner'
gem 'brcpfcnpj'
gem 'paper_trail'
gem 'pushmeup'
gem 'atomic_arrays'

group :production do
  gem 'rails_12factor'
  gem 'unicorn'
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
  gem 'rspec-rails', '~> 3.0.0.beta'
  gem 'database_cleaner'
  gem 'awesome_print'
  gem 'shoulda-matchers'
  gem 'pry', '0.9.12.2'
  gem 'pry-nav'
end

group :development do
  gem 'foreman'
end
