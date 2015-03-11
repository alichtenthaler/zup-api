class NotificationPusher
  include Sidekiq::Worker

  # Send push notification for mobile clients
  def perform(user_id, message)
    user = User.find(user_id)

    device_type = user.device_type
    device_token = user.device_token

    if device_type == 'ios'
      APNS.send_notification(
        device_token,
        alert: message,
        badge: 1
      )
    elsif device_type == 'android'
      GCM.send_notification(
        device_token,
        message: message,
        user_id: user_id
      )
    end
  end
end
