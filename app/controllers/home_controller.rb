# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @app_name = ENV.fetch("APP_NAME", "App")
  end
end
