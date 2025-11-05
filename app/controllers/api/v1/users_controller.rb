class Api::V1::UsersController < ApplicationController
  def create
    user = User.new(user_params)
    if user.save
      result = ::JsonWebToken::Encode.call(payload: { user_id: user.id })
      render json: { token: result.token, user: user.slice(:id, :email) }, status: :created
    else
      render json: {
        error: {
          code: "VALIDATION_ERROR",
          message: "User creation failed",
          details: user.errors.full_messages
        }
      }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
