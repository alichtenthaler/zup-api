class ZupMailer < ActionMailer::Base
  add_template_helper(DateHelper)
  add_template_helper(ReportHelper)

  before_action :validate_email
  sender_email = ENV['SENDER_EMAIL'] || 'suporte@zeladoriaurbana.com.br'
  sender_name = ENV['SENDER_NAME'] || 'Suporte ZUP'
  default from: "#{sender_name} <#{sender_email}>",
          content_type: 'text/html'

  # Disables email deliver if the
  # option is false
  def self.perform_deliveries
    ENV['DISABLE_EMAIL_SENDING'] != 'true'
  end

  protected

  # Intercept emails and check on the
  # settings if it should be sent.
  def validate_email
    action_name = @_action_name.to_sym
    unless Settings.can_send_email?(self.class::RESTRICT_ACTIONS[action_name]).inspect
      def self.deliver!
        false
      end
    end
  end
end
