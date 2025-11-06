require 'rails_helper'

RSpec.describe 'POST /api/v1/auth/register', type: :request do
  let(:valid_attributes) do
    {
      user: {
        email: 'newuser@example.com',
        password: 'password123'
      }
    }
  end

  describe 'validation failures' do
    context 'when email is missing' do
      it 'returns unprocessable entity status' do
        invalid_params = { user: { password: 'password123' } }

        post '/api/v1/auth/register', params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns validation error' do
        invalid_params = { user: { password: 'password123' } }

        post '/api/v1/auth/register', params: invalid_params, as: :json

        expect(json_response['error']).to eq('Validation failed')
        expect(json_response['details']).to be_an(Array)
      end

      it 'does not create a user' do
        invalid_params = { user: { password: 'password123' } }

        expect {
          post '/api/v1/auth/register', params: invalid_params, as: :json
        }.not_to change(User, :count)
      end
    end

    context 'when email format is invalid' do
      it 'returns validation error' do
        invalid_params = valid_attributes.deep_merge(user: { email: 'invalid' })

        post '/api/v1/auth/register', params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['details']).to include(
          match(/Email must be a valid email address/)
        )
      end
    end

    context 'when password is too short' do
      it 'returns validation error' do
        invalid_params = valid_attributes.deep_merge(user: { password: 'short' })

        post '/api/v1/auth/register', params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['details']).to include(
          match(/Password must be at least 8 characters/)
        )
      end
    end

    context 'when email already exists' do
      before { create(:user, email: 'existing@example.com') }

      it 'returns validation error from contract' do
        duplicate_params = valid_attributes.deep_merge(
          user: { email: 'existing@example.com' }
        )

        post '/api/v1/auth/register', params: duplicate_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['details']).to include(
          match(/Email has already been taken/)
        )
      end
    end
  end

  describe 'token generation failure' do
    it 'returns error when token encoding fails' do
      allow(JsonWebToken::Encode).to receive(:call).and_return(
        double(success?: false, error: 'Token generation failed')
      )

      post '/api/v1/auth/register', params: valid_attributes, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['error']).to eq('Token generation failed')
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
