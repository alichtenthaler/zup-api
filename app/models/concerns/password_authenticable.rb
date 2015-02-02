module PasswordAuthenticable
  extend ActiveSupport::Concern

  included do
    attr_accessor :current_password, :password, :password_confirmation,
                  :resetting_password, :old_encrypted_password

    before_validation :encrypt_password
    after_create :clear_password_attributes

    validates_presence_of :password, :password_confirmation,
      if: :should_require_password_fields?
    validates :password, length: { in: 6..16 }, if: :should_require_password_fields?

    validate :presence_of_current_password
  end

  # Encrypts passwords
  def self.crypt(password, salt)
    digest = OpenSSL::Digest::SHA256.new
    Armor.digest(
      password.to_s,
      salt
    )
  end

  # Encrypts the user password
  def encrypt_password
    unless self.password.blank?
      unless self.salt
        begin
          self.salt = SecureRandom.hex
        end while self.class.find_by(salt: salt)
      end

      unless encrypted_password.blank?
        self.old_encrypted_password = encrypted_password
      end

      self.encrypted_password = \
        PasswordAuthenticable.crypt(password, salt)
    end
  end

  # After creation clear passwords
  def clear_password_attributes
    self.password = self.password_confirmation = nil
  end

  # Check if given password is the user's password
  def check_password(password_to_compare, c = nil)
    c = encrypted_password unless c

    return PasswordAuthenticable.eql_time_cmp(
      c,
      PasswordAuthenticable.crypt(password_to_compare, self.salt)
    )
  end

  # Generate a token for password resetting
  def generate_reset_password_token!
    token = SecureRandom.hex
    self.update(reset_password_token: token)
  end

  def should_require_password_fields?
    new_record?
  end

  def presence_of_current_password
    permissions = UserAbility.new(self)

    # If is an existent record
    # and the password attribute is present
    # and the current_password
    # or the informed one is inequal to current
    # and is not resetting the password
    if !permissions.can?(:manage, User) &&
       !new_record? &&
       password.present? &&
       (
        current_password.blank? ||
        !check_password(current_password, old_encrypted_password)
       ) &&
       !resetting_password

      errors.add(:current_password, 'needs to be informed')
    end
  end

  module ClassMethods
    # Authenticates email and password
    def authenticate(email, password)
      if (user = find_by(email: email))
        if user.check_password(password)
          user.generate_access_key!
          return user.reload
        else
          return false
        end
      else
        return false
      end
    end

    # Starts password recovery proceedings
    # Generate a reset password token and
    # send e-mail.
    def request_password_recovery(email)
      user = self.find_by(email: email)

      if user
        user.generate_reset_password_token!
        UserMailer.delay.send_password_recovery_instructions(user)

        return true
      else
        return false
      end
    end

    # Resets the password
    def reset_password(token, new_password)
      user = self.find_by(reset_password_token: token)

      if user
        user.resetting_password = true
        user.update(password: new_password, reset_password_token: nil)
      end
    end
  end

  # Compare strings with equal
  # amount of time.
  def self.eql_time_cmp(a, b)
    unless a.length == b.length
      return false
    end

    cmp = b.bytes.to_a

    result = 0
    a.bytes.each_with_index {|c,i|
      result |= c ^ cmp[i]
    }

    result == 0
  end
end
