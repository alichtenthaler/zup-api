if (Rails.env.production? || Rails.env.deployment?) && !(ENV['AWS_ACCESS_KEY_ID'].nil? || ENV['AWS_SECRET_ACCESS_KEY'].nil?)
  CarrierWave.configure do |config|
    config.fog_credentials = {
        provider: 'AWS',
        aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    }

    config.fog_directory = ENV['AWS_DEFAULT_IMAGE_BUCKET']
    config.storage = :fog
  end
else
  CarrierWave.configure do |config|
    config.storage = :file
    config.asset_host = ActionController::Base.asset_host

    if Rails.env.test?
      config.enable_processing = false
    else
      config.enable_processing = true
    end
  end
end
