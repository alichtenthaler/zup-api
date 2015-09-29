# This file is used by Rack-based servers to start the application.
require ::File.expand_path('../application',  __FILE__)

if ENV['RACK_ENV'] == 'profile'
  use StackProf::Middleware, enabled: true,
      mode: :cpu,
      interval: 1000,
      save_every: 5
end

run ZupServer
