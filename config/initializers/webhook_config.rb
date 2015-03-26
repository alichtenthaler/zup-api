class Webhook
  cattr_accessor :url

  def self.enabled?
    !url.nil?
  end
end

Webhook.url = ENV['WEBHOOK_URL']
