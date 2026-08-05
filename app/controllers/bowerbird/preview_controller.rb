# frozen_string_literal: true

require "openssl"
require "securerandom"

module Bowerbird
  # Auto-login for Bowerbird studio "Open live app".
  # HMAC payload: email|name|exp with BOWERBIRD_PREVIEW_SECRET.
  class PreviewController < ApplicationController
    skip_before_action :authenticate_user!, raise: false
    skip_before_action :verify_authenticity_token, raise: false

    def enter
      unless ENV["BOWERBIRD_PREVIEW_SECRET"].to_s.present?
        redirect_to new_user_session_path, alert: "Preview login is not configured."
        return
      end

      unless valid_signature?
        redirect_to new_user_session_path,
                    alert: "This preview link is invalid or expired. Open the app again from Bowerbird."
        return
      end

      email = params[:email].to_s.strip.downcase
      name = params[:name].to_s.strip.presence || email.split("@").first
      password = ENV["BOWERBIRD_OWNER_PASSWORD"].presence || SecureRandom.alphanumeric(20)

      user = User.find_or_initialize_by(email: email)
      user.name = name if user.name.blank? || user.new_record?
      if user.new_record?
        user.password = password
        user.password_confirmation = password
      end
      user.role = "admin"
      user.admin = true
      user.save!

      # remember_me: durable cookie so redeploys don't force another Open live app.
      if user.respond_to?(:remember_me=)
        user.remember_me = true
      end
      sign_in(user, remember_me: true)
      redirect_to root_path, notice: "Signed in as #{user.display_name}."
    rescue StandardError => e
      Rails.logger.error("[Bowerbird::Preview] #{e.class}: #{e.message}")
      redirect_to new_user_session_path, alert: "Could not sign you in automatically. Try again from Bowerbird."
    end

    private

    def valid_signature?
      exp = params[:exp].to_i
      return false if exp <= 0 || Time.now.to_i > exp

      email = params[:email].to_s.strip.downcase
      name = params[:name].to_s
      sig = params[:sig].to_s
      return false if email.blank? || sig.blank?

      payload = [email, name, exp.to_s].join("|")
      expected = OpenSSL::HMAC.hexdigest("SHA256", ENV.fetch("BOWERBIRD_PREVIEW_SECRET"), payload)
      return false if expected.bytesize != sig.bytesize

      ActiveSupport::SecurityUtils.secure_compare(expected, sig)
    rescue StandardError
      false
    end
  end
end
