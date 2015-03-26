class AuthenticationController < ApplicationController
  def twitter_callback
    unless request.env['omniauth.auth'].nil?
      user_info = request.env['omniauth.auth']
      session[:user_info] = {
          name: user_info.info.name,
          twitter_uid: user_info.uid
      }
    end

    # TODO: figure out how we are going to pass this to the client
  end

  def facebook_callback
    unless request.env['omniauth.auth'].nil?
      user_info = request.env['omniauth.auth']
      session[:user_info] = {
          name: user_info.info.name,
          facebook_uid: user_info.uid,
          email: user_info.info.email
      }
    end

    # TODO: figure out how we are going to pass this to the client
  end

  def google_callback
    unless request.env['omniauth.auth'].nil?
      user_info = request.env['omniauth.auth']
      session[:user_info] = {
          name: user_info.info.name,
          google_uid: user_info.uid,
          email: user_info.info.email
      }
    end

    # TODO: figure out how we are going to pass this to the client
  end
end
