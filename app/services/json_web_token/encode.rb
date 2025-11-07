class JsonWebToken::Encode
  include Interactor

    def call
      payload = context.payload.presence or context.fail!(error: "Payload is required")

      context.token = JWT.encode(
        payload.merge(exp: expiration_time),
        secret_key,
        "HS256"
      )
    rescue StandardError => e
      context.fail!(error: "Token encoding failed: #{e.message}")
    end

  private

  def expiration_time
    (context.exp || 24.hours.from_now).to_i
  end

  def secret_key
    ENV.fetch("JWT_SECRET_KEY", nil)
  end
end
