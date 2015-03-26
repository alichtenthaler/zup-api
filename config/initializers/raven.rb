unless Rails.env.development?
  require 'raven'
  Raven.configure do |config|
    config.environments = %w(production)
    config.dsn = 'https://9fbb6a2033064b7fb29ad22ebbf2dc34:6b16f6a42ad84e9796b974d68859c40c@app.getsentry.com/17327'
  end
else
  class Raven
    def self.capture_exception(e)
      fail e
    end
  end
end
