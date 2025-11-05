class Api::V1::SessionsController < ApplicationController
  def create
    user = User.find_by("lower(email) = ?", session_params[:email].downcase)

    if user&.authenticate(session_params[:password])
      token = JsonWebToken::Encode.call(payload: { user_id: user.id }).token
      render json: { token:, user: user.slice(:id, :email) }, status: :ok
    else
      render json: {
        error: {
          code: "UNAUTHORIZED",
          message: "Invalid email or password"
        }
      }, status: :unauthorized
    end
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
