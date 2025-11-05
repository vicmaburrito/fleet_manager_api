class JsonWebToken::Encode
  include Interactor

  def call
    context.fail!(error: 'Payload is required') if context.payload.blank?

    begin
      context.token = JWT.encode(
        context.payload.merge(exp: expiration_time),
        jwt_secret_key,
        'HS256'
      )
    rescue StandardError => e
      context.fail!(error: "Token encoding failed: #{e.message}")
    end
  end

  private

  def expiration_time
    (context.exp || 24.hours.from_now).to_i
  end

  def jwt_secret_key
    ENV['JWT_SECRET_KEY'] || raise('JWT_SECRET_KEY not configured')
  end
end
