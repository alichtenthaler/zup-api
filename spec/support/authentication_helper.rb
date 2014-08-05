class Hash
  def auth(user)
    self[:token] = user.last_access_key
    self
  end
end

module AuthenticationHelper
  def auth(user)
    { "X-App-Token" => user.last_access_key }
  end
end
