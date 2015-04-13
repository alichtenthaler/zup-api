module ApplicationHelper
  def url_for_mailer(path)
    "#{ENV["API_URL"]}/" + path
  end

  def header_for_mailer
    url_for_mailer(ENV['MAIL_HEADER_IMAGE'] || 'images/header.jpg')
  end
end
