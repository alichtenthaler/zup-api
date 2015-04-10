require 'uri'
require 'net/http'

module Reports
  class SendThroughWebhook
    attr_reader :report

    def initialize(report)
      @report = report
    end

    def send!
      return unless Webhook.enabled?

      serialized_report = serialize_report

      uri = URI(Webhook.url)
      https = Net::HTTP.new(uri.host, 80)

      request = Net::HTTP::Post.new(uri.path)
      https.request(request, { string_json: serialized_report }.to_json)
    end

    private

    def serialize_report
      Reports::SerializeToWebhook.new(report).serialize
    end
  end
end
