class NotificationPusher
  include Sidekiq::Worker

  # Send push notification for mobile clients
  def perform(user_id, report_item_id, previous_status, count)
    user = User.find(user_id)
    report_item = Reports::Item.find(report_item_id)

    device_type = user.device_type
    device_token = user.device_token

    if device_type == 'ios'
      APNS.send_notification(
        device_token,
        alert: \
          "Seu relato mudou para o status '#{report_item.status.title}'",
        badge: 1
      )
    end
  end
end
