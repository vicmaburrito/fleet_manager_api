class Api::V1::Auth::RegistrationsController < ApplicationController
  def create
    contract_result = Auth::RegistrationContract.new.call(user_params.to_h)

    if contract_result.failure?
      return render json: {
        error: "Validation failed",
        details: format_contract_errors(contract_result.errors)
      }, status: :unprocessable_content
    end

    user = User.new(contract_result.to_h)

    if user.save
      result = ::JsonWebToken::Encode.call(payload: { user_id: user.id })

      if result.success?
        render json: {
          token: result.token,
          user: UserSerializer.new(user)
        }, status: :created
      else
        render json: { error: result.error }, status: :unprocessable_content
      end
    else
      render json: {
        error: "User creation failed",
        details: user.errors.full_messages
      }, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end

  def format_contract_errors(errors)
    errors.to_h.flat_map do |key, messages|
      messages.map { |msg| "#{key.to_s.humanize} #{msg}" }
    end
  end
end
