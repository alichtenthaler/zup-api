Sidekiq.configure_server do |config|
  config.redis = { :url => 'redis://172.17.9.118:6379', :namespace => 'zup' }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => 'redis://172.17.9.118:6379', :namespace => 'zup' }
end
