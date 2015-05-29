# This worker is responsible to clear very old access keys
# and mark old access keys as expired
class ExpireAccessKeys
  include Sidekiq::Worker

  def perform
    # Remove very old access keys
    AccessKey.where('created_at < ?', 6.months.ago).destroy_all

    # Expire old access_keys
    AccessKey.where('created_at < ?', 1.day.ago).update_all(expired: true, expired_at: Time.now)
  end
end
