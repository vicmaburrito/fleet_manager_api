require 'swagger_helper'

RSpec.describe 'API::V1::Auth::Sessions', type: :request do
  path '/api/v1/auth/login' do
    post('User login') do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'user@example.com' },
              password: { type: :string, example: 'password123' }
            },
            required: %w[email password]
          }
        },
        required: ['user']
      }

      response(200, 'successful login') do
        let(:user_record) { create(:user, email: 'user@example.com', password: 'password123') }
        let(:user) { { user: { email: user_record.email, password: 'password123' } } }

        schema type: :object,
               properties: {
                 token: { type: :string },
                 user: {
                   type: :object,
                   properties: {
                    id: { type: :integer },
                    email: { type: :string },
                    created_at: { type: :string }
                   }
                 }
               },
               required: %w[token user]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['token']).to be_present
          expect(data['user']['email']).to eq('user@example.com')
        end
      end

      response(401, 'invalid credentials') do
        let(:user_record) { create(:user, email: 'user@example.com', password: 'password123') }
        let(:user) { { user: { email: user_record.email, password: 'wrongpassword' } } }

        schema type: :object,
               properties: {
                 error: {
                   type: :object,
                   properties: {
                     code: { type: :string },
                     message: { type: :string }
                   },
                   required: %w[code message]
                 }
               }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body['error']['code']).to eq('invalid_credentials')
        end
      end

      response(422, 'validation failed') do
        let(:user) { { user: { email: '', password: '' } } }

        schema type: :object,
               properties: {
                 error: {
                   type: :object,
                   properties: {
                     code: { type: :string },
                     message: { type: :string },
                     details: { type: :object }
                   },
                   required: %w[code message]
                 }
               }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body['error']['code']).to eq('validation_failed')
          expect(body['error']['details']).to be_present
        end
      end
    end
  end

  path '/api/v1/auth/logout' do
    delete('logout') do
      tags 'Auth'
      security [ bearerAuth: [] ]
      produces 'application/json'

      response(204, 'no content') do
        let(:user) { create(:user) }
        let(:token) { JsonWebToken::Encode.call(payload: { user_id: user.id }).token }
        let(:Authorization) { "Bearer #{token}" }

        run_test!
      end
    end
  end
end
