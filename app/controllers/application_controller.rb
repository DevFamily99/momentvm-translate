class ApplicationController < ActionController::Base
  BASIC_AUTH_USERNAME = ENV['BASIC_AUTH_USERNAME']
  BASIC_AUTH_PASSWORD = ENV['BASIC_AUTH_PASSWORD']
  http_basic_authenticate_with name: BASIC_AUTH_USERNAME, password: BASIC_AUTH_PASSWORD
end
