class AccessKey < ActiveRecord::Base
  belongs_to :user

  validates :key, presence: true
  validates :user, presence: true

  scope :active, -> { where(expired: false) }
  scope :expired, -> { where(expired: true) }

  before_validation :random_key

  def expire!
    unless expired?
      update!(
        expired: true,
        expired_at: Time.now
      )
    end
  end

  private

  def random_key
    self.key ||= SecureRandom.hex
  end
end
