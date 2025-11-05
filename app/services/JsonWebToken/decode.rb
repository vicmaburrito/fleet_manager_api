class JsonWebToken::Decode
  include Interactor

  def call
    context.fail!(error: 'Token is required') if context.token.blank?

    begin
      decoded = JWT.decode(
        context.token,
        jwt_secret_key,
        true,
        { algorithm: 'HS256' }
      )
      context.payload = decoded[0].with_indifferent_access
    rescue JWT::ExpiredSignature
      context.fail!(error: 'Token has expired')
    rescue JWT::DecodeError => e
      context.fail!(error: "Invalid token: #{e.message}")
    end
  end

  private

  def jwt_secret_key
    ENV['JWT_SECRET_KEY'] || raise('JWT_SECRET_KEY not configured')
  end
end
