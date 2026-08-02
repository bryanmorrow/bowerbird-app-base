# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  layout :resolve_layout


  # AUTH_REQUIRED=true (default) enforces Devise login except public paths.
  # Set AUTH_REQUIRED=false for fully public apps (interview no_login).
  before_action :authenticate_user!, if: :auth_required?

  helper_method :auth_required?

  private

  def resolve_layout
    devise_controller? ? "auth" : "application"
  end

  def auth_required?
    return false if devise_controller?

    ENV.fetch("AUTH_REQUIRED", "true") != "false"
  end
end
