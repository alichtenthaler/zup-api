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

      serialized_report = serialize_report(report)

      uri = URI(Webhook.url)
      http = Net::HTTP.new(uri.host, 80)

      request = Net::HTTP::Post.new(uri.path)
      https.request({ string_json: serialized_report }.to_json)
    end

    private

    def serialize_report
      Reports::SerializeToWebhook.new(report).serialize
    end
  end
end
