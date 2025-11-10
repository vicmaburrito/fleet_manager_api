require 'openapi_helper'

RSpec.describe 'Authentication - Registration', type: :request do
  path '/api/v1/auth/register' do
    post 'Register a new user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      description 'Creates a new user account and returns a JWT authentication token'

      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: {
                type: :string,
                format: :email,
                description: 'User email address',
                example: 'user@example.com'
              },
              password: {
                type: :string,
                format: :password,
                description: 'User password (minimum 8 characters)',
                example: 'password123',
                minLength: 8
              }
            },
            required: %w[email password]
          }
        },
        required: [ 'user' ]
      }

      response '201', 'User successfully created' do
        schema type: :object,
          properties: {
            token: {
              type: :string,
              description: 'JWT authentication token',
              example: 'eyJhbGciOiJIUzI1NiJ9...'
            },
            user: {
              type: :object,
              properties: {
                id: { type: :integer, example: 1 },
                email: { type: :string, example: 'newuser@example.com' },
                created_at: { type: :string, format: 'date-time' },
                updated_at: { type: :string, format: 'date-time' }
              }
            }
          },
          required: %w[token user]

        let(:user_params) do
          {
            user: {
              email: 'newuser@example.com',
              password: 'password123'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('token')
          expect(data['token']).to be_present
          expect(data['user']['email']).to eq('newuser@example.com')
          expect(data['user']).not_to have_key('password_digest')
        end
      end

      response '422', 'Validation failed - Email missing' do
        schema type: :object,
          properties: {
            error: { type: :string, example: 'Validation failed' },
            details: {
              type: :array,
              items: { type: :string },
              example: [ 'Email is missing' ]
            }
          }

        let(:user_params) { { user: { password: 'password123' } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to eq('Validation failed')
          expect(data['details']).to be_an(Array)
        end
      end

      response '422', 'Validation failed - Invalid email format' do
        schema type: :object,
          properties: {
            error: { type: :string },
            details: { type: :array, items: { type: :string } }
          }

        let(:user_params) do
          {
            user: {
              email: 'invalid',
              password: 'password123'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_content)
          expect(data['details']).to include(match(/Email must be a valid email address/))
        end
      end

      response '422', 'Validation failed - Password too short' do
        schema type: :object,
          properties: {
            error: { type: :string },
            details: { type: :array, items: { type: :string } }
          }

        let(:user_params) do
          {
            user: {
              email: 'user@example.com',
              password: 'short'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_content)
          expect(data['details']).to include(match(/Password must be at least 8 characters/))
        end
      end

      response '422', 'Validation failed - Email already exists' do
        schema type: :object,
          properties: {
            error: { type: :string },
            details: { type: :array, items: { type: :string } }
          }

        before do
          create(:user, email: 'existing@example.com')
        end

        let(:user_params) do
          {
            user: {
              email: 'existing@example.com',
              password: 'password123'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_content)
          expect(data['details']).to include(match(/Email has already been taken/))
        end
      end

      response '422', 'Validation failed - Password missing' do
        schema type: :object,
          properties: {
            error: { type: :string },
            details: { type: :array, items: { type: :string } }
          }

        let(:user_params) { { user: { email: 'test@example.com' } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to eq('Validation failed')
        end
      end

      response '400', 'Bad request - User wrapper missing' do
        schema type: :object,
          properties: {
            error: { type: :string, example: 'Invalid parameters' },
            message: { type: :string, example: 'param is missing or the value is empty: user' }
          }

        let(:user_params) { { email: 'test@example.com', password: 'password123' } }

        run_test! do |response|
          expect(response).to have_http_status(:bad_request)
        end
      end

      response '422', 'Token generation failed' do
        schema type: :object,
          properties: {
            error: { type: :string, example: 'Token generation failed' }
          }

        before do
          allow(JsonWebToken::Encode).to receive(:call).and_return(
            double(success?: false, error: 'Token generation failed')
          )
        end

        let(:user_params) do
          {
            user: {
              email: 'user@example.com',
              password: 'password123'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_content)
          expect(data['error']).to eq('Token generation failed')
        end
      end
    end
  end
end
