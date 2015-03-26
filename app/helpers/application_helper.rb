module ApplicationHelper
  def url_for_mailer(path)
    "#{ENV["API_URL"]}/" + path
  end
end
