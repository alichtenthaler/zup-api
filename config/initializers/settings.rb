# noinspection ALL
class Settings < Settingslogic
  source "#{Rails.root}/config/settings.yml"
  namespace Rails.env

  def self.can_send_email?(kind)
    if !email_notification.all
      return false
    end

    email_notification[kind.to_s] || true
  end
end
