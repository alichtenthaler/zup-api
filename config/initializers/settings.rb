# noinspection ALL
class Settings < Settingslogic
  source "#{Rails.root}/config/settings.yml"
  namespace Rails.env

  def self.can_send_email?(kind)
    if !self.email_notification.all
      return false
    end

    self.email_notification[kind.to_s] || true
  end
end
