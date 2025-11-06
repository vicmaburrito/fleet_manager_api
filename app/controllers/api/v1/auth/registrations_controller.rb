class Api::V1::Auth::RegistrationsController < ApplicationController
  def create
    user = User.new(user_params)

    if user.save
      result = ::JsonWebToken::Encode.call(payload: { user_id: user.id })

      if result.success?
        render json: {
          token: result.token,
          user: UserSerializer.new(user)
        }, status: :created
      else
        render json: { error: result.error }, status: :unprocessable_entity
      end
    else
      render_validation_errors(user)
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end

  def render_validation_errors(user)
    render json: {
      error: "Validation failed",
      message: "User creation failed",
      details: user.errors.full_messages
    }, status: :unprocessable_entity
  end
end
