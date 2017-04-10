#
#
#
class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook

    outcome = Oauth::HandleCallback.run(:auth => env["omniauth.auth"], :auth_params => env['omniauth.params'], :user => current_user)

    if outcome.success?

      @user = outcome.result.get_user

      case outcome.result.get_type

        when :created # User was just created
          set_flash_message(:notice, :success, kind: "facebook".capitalize) if is_navigational_format?
          sign_in_and_redirect @user, event: :authentication
        when :exists # User already existed to begin wit
          set_flash_message(:notice, :success, kind: "facebook".capitalize) if is_navigational_format?
          sign_in_and_redirect @user, event: :authentication
        when :network_attach # User and account already existed at some point -- request a fb page/etc network attach
          if outcome.result.get_subtype == 'fbpage'
            redirect_to facebook_connections_path(outcome.result.get_account.id)
          elsif outcome.result.get_subtype == 'fbprofile'
            redirect_to network_connections_path(outcome.result.get_account.id)
          else
            raise ArgumentError.new("Invalid subtype")
          end
        when :stream_attach
          redirect_to stream_attach_util_close_window_path # Redirect to the page that will close the popup window
        else # shouldn't happen!
      end
    else
      session["devise.facebook_data"] = env["omniauth.auth"]
      redirect_to new_user_registration_url
    end

  end

  def twitter

    outcome = Oauth::HandleCallback.run(:auth => env["omniauth.auth"], :auth_params => env['omniauth.params'], :user => current_user)

    if outcome.success?
      @user = outcome.result.get_user

      case outcome.result.get_type

        when :created # User was just created
          set_flash_message(:notice, :success, kind: "twitter".capitalize) if is_navigational_format?
          sign_in_and_redirect @user, event: :authentication
        when :exists # User already existed to begin wit
          set_flash_message(:notice, :success, kind: "twitter".capitalize) if is_navigational_format?
          sign_in_and_redirect @user, event: :authentication
        when :network_attach # User and account already existed at some point
          if outcome.result.get_subtype == 'twitterprofile'
            redirect_to network_connections_path(outcome.result.get_account.id)
          else
            raise ArgumentError.new("Invalid subtype")
          end
        when :stream_attach
          redirect_to stream_attach_util_close_window_path # Redirect to the page that will close the popup window
        else # shouldn't happen!
      end
    else
      session["devise.twitter_data"] = env["omniauth.auth"]
      redirect_to new_user_registration_url
    end

  end

  def instagram

    outcome = Oauth::HandleCallback.run(:auth => env["omniauth.auth"], :auth_params => env['omniauth.params'], :user => current_user)

    if outcome.success?
      @user = outcome.result.get_user

      case outcome.result.get_type

        when :created # User was just created
          set_flash_message(:notice, :success, kind: "instagram".capitalize) if is_navigational_format?
          sign_in_and_redirect @user, event: :authentication
        when :exists # User already existed to begin wit
          set_flash_message(:notice, :success, kind: "instagram".capitalize) if is_navigational_format?
          sign_in_and_redirect @user, event: :authentication
        when :network_attach # User and account already existed at some point
          if outcome.result.get_subtype == 'instagramprofile'
            redirect_to network_connections_path(outcome.result.get_account.id)
          else
            raise ArgumentError.new("Invalid subtype")
          end
        when :stream_attach
          redirect_to stream_attach_util_close_window_path # Redirect to the page that will close the popup window
        else # shouldn't happen!
      end
    else
      session["devise.instagram_data"] = env["omniauth.auth"]
      redirect_to new_user_registration_url
    end

  end

  def after_sign_in_path_for(resource)
    app_path
  end
end