class JsonWebToken::Decode
  include Interactor

  def call
  token = context.token.presence or context.fail!(error: "Token is required")

  decoded = JWT.decode(token, secret_key, true, { algorithm: "HS256" })
  context.payload = decoded.first.with_indifferent_access
  rescue JWT::ExpiredSignature
    context.fail!(error: "Token has expired")
  rescue JWT::DecodeError => e
    context.fail!(error: "Invalid token: #{e.message}")
  end

  private

  def secret_key
    ENV.fetch("JWT_SECRET_KEY", nil)
  end
end
