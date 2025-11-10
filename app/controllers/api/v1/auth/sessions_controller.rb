class Api::V1::Auth::SessionsController < Api::V1::Auth::BaseController
  skip_before_action :authenticate_user!, only: :create

  def create
    contract_result = Auth::LoginContract.new.call(login_params.to_h)

    if contract_result.failure?
      return render json: {
        error: {
          code: "validation_failed",
          message: "Invalid input data",
          details: format_contract_errors(contract_result.errors)
        }
      }, status: :unprocessable_content
    end

    user = User.authenticate_by(email: contract_result[:email].downcase, password: contract_result[:password])

    if user
      render_successful_login(user)
    else
      render json: {
        error: {
          code: "invalid_credentials",
          message: "Email or password is incorrect"
        }
      }, status: :unauthorized
    end
  end

  def destroy
    head :no_content
  end

  private

  def login_params
    params.require(:user).permit(:email, :password)
  end

  def render_successful_login(user)
    result = ::JsonWebToken::Encode.call(payload: { user_id: user.id })

    if result.success?
      render json: {
        token: result.token,
        user: UserSerializer.new(user)
      }, status: :ok
    else
      render json: {
        error: {
          code: "token_generation_failed",
          message: result.error
        }
      }, status: :unprocessable_content
    end
  end

  def format_contract_errors(errors)
    errors.to_h.transform_values { |messages| messages.join(", ") }
  end
end
