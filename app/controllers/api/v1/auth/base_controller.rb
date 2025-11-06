class Api::V1::Auth::BaseController < ApplicationController
  before_action :authenticate_user!, except: [ :create ]

  rescue_from ActionController::ParameterMissing, with: :invalid_params

  private

  def invalid_params(exception)
    render json: {
      error: "Invalid parameters",
      message: exception.message
    }, status: :unprocessable_entity
  end

  def current_user
    @current_user ||= begin
      token = extract_token
      return if token.blank?

      result = ::JsonWebToken::Decode.call(token: token)
      User.find_by(id: result.payload[:user_id]) if result.success?
    end
  end

  def authenticate_user!
    return if current_user.present?

    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def extract_token
    request.headers["Authorization"]&.split&.last
  end
end
