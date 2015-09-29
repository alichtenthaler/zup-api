class SendReportThroughWebhook
  include Sidekiq::Worker

  sidekiq_options queue: :webhook, retry: 5, backtrace: true

  def perform(report_id)
    report = Reports::Item.find(report_id)
    Reports::SendThroughWebhook.new(report).send!
  end
end
