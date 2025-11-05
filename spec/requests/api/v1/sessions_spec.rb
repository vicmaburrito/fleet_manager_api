# spec/requests/api/v1/sessions_spec.rb
require 'rails_helper'

RSpec.describe 'API V1 Sessions', type: :request do
  let(:headers) { { 'Content-Type': 'application/json' } }
  let(:user) { create(:user, email: 'login@example.com', password: 'password123') }

  describe 'POST /api/v1/sessions' do
    context 'with valid credentials' do
      it 'authenticates the user and returns a JWT token' do
        params = { session: { email: user.email, password: 'password123' } }

        post '/api/v1/sessions', params: params.to_json, headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['token']).to be_present
        expect(json['user']['email']).to eq(user.email)

        decoded = JWT.decode(json['token'], ENV['JWT_SECRET_KEY'], true, { algorithm: 'HS256' })
        expect(decoded[0]['user_id']).to eq(user.id)
      end
    end

    context 'with invalid credentials' do
      it 'returns an unauthorized error' do
        params = { session: { email: user.email, password: 'wrongpassword' } }

        post '/api/v1/sessions', params: params.to_json, headers: headers

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']['code']).to eq('UNAUTHORIZED')
        expect(json['error']['message']).to eq('Invalid email or password')
      end
    end
  end
end
