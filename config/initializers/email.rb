if Application.config.env.development?
  class DevelopmentInterceptor
    def self.delivering_email(message)
      message.to  = "\"#{message.to.first}\" <estevao.am@gmail.com>"
      message.cc, message.bcc = nil, nil
    end
  end

  ActionMailer::Base.register_interceptor(DevelopmentInterceptor)
end
