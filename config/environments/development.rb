ActiveRecord::Base.logger = Logger.new(STDOUT)

class CacheStore
  def fetch(*_args)
    yield
  end
end

Application.config.cache = CacheStore.new
