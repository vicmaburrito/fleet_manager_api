class Auth::RegistrationContract < Dry::Validation::Contract
  params do
    required(:email).filled(:string)
    required(:password).filled(:string)
  end

  rule(:email) do
    unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
      key.failure("must be a valid email address")
    end
  end

  rule(:password) do
    key.failure("must be at least 8 characters") if value.length < 8
  end

  rule(:email) do
    if User.exists?(email: value)
      key.failure("has already been taken")
    end
  end
end
