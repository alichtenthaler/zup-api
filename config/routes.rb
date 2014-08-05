require 'sidekiq/web'

ZupApi::Application.routes.draw do
  mount ZUP::API => '/'
  mount GrapeSwaggerRails::Engine => '/swagger'

  # TODO: Ensure authentication for this
  mount Sidekiq::Web => '/sidekiq'

  root 'application#index'

  # 3rd party auth strategies
  get '/auth/twitter/callback' => 'authentication#twitter_callback'
  get '/auth/facebook/callback' => 'authentication#facebook_callback'
  get '/auth/google_oauth2/callback' => 'authentication#google_callback'
end
