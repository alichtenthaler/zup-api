case Application.config.env.to_sym
when :production || :staging
  require 'raven'
  Raven.configure do |config|
    config.environments = %w(production staging)
    config.dsn = ENV['SENTRY_DSN_URL'] || 'https://9fbb6a2033064b7fb29ad22ebbf2dc34:6b16f6a42ad84e9796b974d68859c40c@app.getsentry.com/17327'
  end
when :development
  class Raven
    def self.capture_exception(e)
      fail e
    end
  end
else
  class Raven
    def self.capture_exception(_e)
      # Do nothing
    end
  end
end
