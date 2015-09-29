require 'digest/sha1'

class CustomCacheControl
  attr_reader :klass, :params, :user

  def initialize(klass, user, params)
    @klass = klass
    @user = user
    @params = params
  end

  def garner_cache_key
    if last_updated_at
      unique_string = "#{last_updated_at}/user/#{user.try(:id) || 0}/#{group_permission_last_updated_at}/#{params}"
      "#{klass.name.titleize.downcase}/#{Digest::SHA1.hexdigest(unique_string)}"
    end
  end

  private

  def last_updated_at
    @last_updated_at ||= klass.order(updated_at: :desc).try(:first).try(:updated_at)
  end

  def group_permission_last_updated_at
    @group_permission_last_updated_at ||= user.groups_permissions.last.updated_at
  rescue
    '0'
  end
end
