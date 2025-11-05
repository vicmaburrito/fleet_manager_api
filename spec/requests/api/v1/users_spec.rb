require 'rails_helper'

RSpec.describe 'API V1 Users', type: :request do
  let(:headers) { { 'Content-Type': 'application/json' } }

  describe 'POST /api/v1/users' do
    it 'creates a new user and returns a JWT token' do
      params = { user: attributes_for(:user, email: 'newuser@example.com') }

      post '/api/v1/users', params: params.to_json, headers: headers

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['token']).to be_present
      expect(json['user']['email']).to eq('newuser@example.com')

      decoded = JWT.decode(json['token'], ENV['JWT_SECRET_KEY'], true, { algorithm: 'HS256' })
      expect(decoded[0]['user_id']).to eq(User.last.id)
    end

    it 'returns error if email already exists' do
      create(:user, email: 'taken@example.com')
      params = { user: attributes_for(:user, email: 'taken@example.com') }

      post '/api/v1/users', params: params.to_json, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']['code']).to eq('VALIDATION_ERROR')
      expect(json['error']['details']).to include('Email has already been taken')
    end
  end
end
