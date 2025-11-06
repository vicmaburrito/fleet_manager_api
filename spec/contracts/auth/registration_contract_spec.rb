require 'rails_helper'

RSpec.describe Auth::RegistrationContract, type: :contract do
  subject(:contract) { described_class.new }

  describe 'valid params' do
    it 'passes with valid email and password' do
      result = contract.call(
        email: 'user@example.com',
        password: 'password123'
      )

      expect(result).to be_success
      expect(result.to_h).to eq(
        email: 'user@example.com',
        password: 'password123'
      )
    end
  end

  describe 'email validation' do
    it 'fails when email is missing' do
      result = contract.call(password: 'password123')

      expect(result).to be_failure
      expect(result.errors[:email]).to include('is missing')
    end

    it 'fails when email is empty' do
      result = contract.call(email: '', password: 'password123')

      expect(result).to be_failure
      expect(result.errors[:email]).to include('must be filled')
    end

    it 'fails with invalid email format' do
      result = contract.call(email: 'invalid-email', password: 'password123')

      expect(result).to be_failure
      expect(result.errors[:email]).to include('must be a valid email address')
    end

    it 'accepts valid email formats' do
      valid_emails = [
        'user@example.com',
        'user.name@example.com',
        'user+tag@example.co.uk',
        'user_name@example-domain.com'
      ]

      valid_emails.each do |email|
        result = contract.call(email: email, password: 'password123')
        expect(result).to be_success, "Expected #{email} to be valid"
      end
    end

    it 'fails when email already exists' do
      create(:user, email: 'existing@example.com')

      result = contract.call(
        email: 'existing@example.com',
        password: 'password123'
      )

      expect(result).to be_failure
      expect(result.errors[:email]).to include('has already been taken')
    end
  end

  describe 'password validation' do
    it 'fails when password is missing' do
      result = contract.call(email: 'user@example.com')

      expect(result).to be_failure
      expect(result.errors[:password]).to include('is missing')
    end

    it 'fails when password is empty' do
      result = contract.call(email: 'user@example.com', password: '')

      expect(result).to be_failure
      expect(result.errors[:password]).to include('must be filled')
    end

    it 'fails when password is too short' do
      result = contract.call(email: 'user@example.com', password: 'short')

      expect(result).to be_failure
      expect(result.errors[:password]).to include('must be at least 8 characters')
    end

    it 'passes with 8 character password' do
      result = contract.call(email: 'user@example.com', password: '12345678')

      expect(result).to be_success
    end

    it 'passes with long password' do
      result = contract.call(
        email: 'user@example.com',
        password: 'a' * 100
      )

      expect(result).to be_success
    end
  end
end
