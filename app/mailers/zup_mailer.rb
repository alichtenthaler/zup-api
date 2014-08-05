class ZupMailer < ActionMailer::Base
  add_template_helper(DateHelper)
  add_template_helper(ReportHelper)

  before_action :validate_email
  default from: "ZUP <zup@zup.sapience.io>"

  # Disables email deliver if the
  # option is false
  def self.perform_deliveries
    Settings.email_notification.all
  end

  protected
    # Intercept emails and check on the
    # settings if it should be sent.
    def validate_email
      action_name = @_action_name.to_sym
      unless Settings.can_send_email?(self.class::RESTRICT_ACTIONS[action_name]).inspect
        def self.deliver! ; false ; end
      end
    end
end
