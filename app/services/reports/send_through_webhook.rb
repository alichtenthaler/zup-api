require 'uri'
require 'net/http'

module Reports
  class SendThroughWebhook
    attr_reader :report

    SLACK_URL = ENV['SLACK_INCOMING_WEBHOOK_URL']
    SLACK_CHANNEL = ENV['SLACK_NOTIFICATION_CHANNEL']

    def initialize(report)
      @report = report
    end

    def send!
      return unless Webhook.enabled?

      serialized_report = serialize_report

      uri = URI(Webhook.url)
      https = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Post.new(uri.path)
      result = https.request(request, serialized_report.to_json)

      unless result.code == '200'
        fail StandardError.new("Requisição de envio retornou código de status: '#{result.code}'")
      end

      logger.info("Relato ##{report.id} enviado com sucesso! Categoria: ##{report.category.id} (#{report.category.title})")
    rescue => e
      message = "Ocorreu um erro ao enviar o relato ##{report.id} via integração:\n #{e.message}"
      send_slack_hook(message)
      logger.error(message)
      Raven.capture_exception(e)
      raise e
    end

    private

    def logger
      Yell.new do |l|
        l.adapter :datefile, File.join(Application.config.root, 'log', 'webhook.log'), level: 'gte.info'
      end
    end

    def serialize_report
      Reports::SerializeToWebhook.new(report).serialize
    rescue Webhook::ExternalCategoryNotFound => e
      # External category not found, let's just log this error for now
      Application.logger.info("Report ##{report.id} isn't for a Webhook category")
    end

    def send_slack_hook(message)
      return nil if SLACK_URL.blank?

      Slackhook.send_hook(
        webhook_url: SLACK_URL,
        text: message,
        icon_type: ':exclamation:'
      )
    end
  end
end
