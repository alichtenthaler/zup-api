Application.eager_load!

class CacheStore
  def fetch(*_args)
    yield
  end
end

Application.config.cache = CacheStore.new
ActionMailer::Base.perform_deliveries = false

if defined?(Appsignal) && Appsignal.config
  Appsignal.config.merge_config(active: false)
end
