
class Auth::LoginContract < Dry::Validation::Contract
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
    key.failure("must be present") if value.blank?
  end
end
