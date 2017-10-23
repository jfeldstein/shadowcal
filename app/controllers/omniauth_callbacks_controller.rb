# frozen_string_literal: true

class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = current_user
    @user ||= User.find_or_create_from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      @user.add_or_update_google_account(request.env["omniauth.auth"])

      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: "Google"
      sign_in_and_redirect @user, event: :authentication
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end
