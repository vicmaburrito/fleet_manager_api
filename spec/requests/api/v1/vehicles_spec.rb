require 'swagger_helper'

RSpec.describe 'API::V1::Vehicles', type: :request do
  let(:user) { build(:user) }
  let(:Authorization) { "Bearer fake-token" }

  before do
    allow_any_instance_of(Api::V1::Auth::BaseController)
      .to receive(:current_user)
      .and_return(user)
  end

  path '/api/v1/vehicles' do
    get 'List vehicles' do
      tags 'Vehicles'
      produces 'application/json'
      security [ bearerAuth: [] ]

      response '200', 'successful' do
        before { create_list(:vehicle, 3) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_present
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { nil }
        before do
          allow_any_instance_of(Api::V1::Auth::BaseController)
            .to receive(:current_user)
            .and_return(nil)
        end

        run_test!
      end
    end

    post 'Create vehicle' do
      tags 'Vehicles'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :vehicle_params, in: :body, schema: {
        type: :object,
        properties: {
          vehicle: {
            type: :object,
            properties: {
              vin: { type: :string, example: '1HGBH41JXMN109186' },
              plate: { type: :string, example: 'ABC1234' },
              brand: { type: :string, example: 'Toyota' },
              model: { type: :string, example: 'Camry' },
              year: { type: :integer, example: 2020 },
              status: { type: :string, example: 'active' }
            },
            required: %w[vin plate brand model year]
          }
        }
      }

      response '201', 'created' do
        let(:vehicle_params) { { vehicle: attributes_for(:vehicle) } }

        run_test! do |response|
          expect(JSON.parse(response.body)).to be_present
        end
      end

      response '422', 'validation failed' do
        let(:vehicle_params) { { vehicle: { vin: '', plate: '' } } }

        run_test! do |response|
          expect(JSON.parse(response.body)['error']).to be_present
        end
      end

      response '401', 'unauthorized' do
        let(:vehicle_params) { { vehicle: attributes_for(:vehicle) } }
        let(:Authorization) { nil }
        before do
          allow_any_instance_of(Api::V1::Auth::BaseController)
            .to receive(:current_user)
            .and_return(nil)
        end

        run_test!
      end
    end
  end

  path '/api/v1/vehicles/{id}' do
    parameter name: :id, in: :path, type: :integer

    get 'Show vehicle' do
      tags 'Vehicles'
      produces 'application/json'
      security [ bearerAuth: [] ]

      response '200', 'found' do
        let(:vehicle) { create(:vehicle) }
        let(:id) { vehicle.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['vehicle']).to be_present
        end
      end

      response '404', 'not found' do
        let(:id) { 999999 }

        run_test!
      end
    end

    patch 'Update vehicle' do
      tags 'Vehicles'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :vehicle_params, in: :body, schema: {
        type: :object,
        properties: {
          vehicle: {
            type: :object,
            properties: {
              brand: { type: :string },
              model: { type: :string }
            }
          }
        }
      }

      response '200', 'updated' do
        let(:vehicle) { create(:vehicle) }
        let(:id) { vehicle.id }
        let(:vehicle_params) { { vehicle: { brand: 'Honda' } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['vehicle']['brand']).to eq('Honda')
        end
      end

      response '422', 'invalid params' do
        let(:vehicle) { create(:vehicle) }
        let(:id) { vehicle.id }
        let(:vehicle_params) { { vehicle: { year: 1800 } } }

        run_test!
      end
    end

    delete 'Delete vehicle' do
      tags 'Vehicles'
      security [ bearerAuth: [] ]

      response '204', 'deleted' do
        let(:vehicle) { create(:vehicle) }
        let(:id) { vehicle.id }

        run_test! do
          expect(Vehicle.kept.exists?(id)).to be_falsey
          expect(Vehicle.with_discarded.find(id)).to be_discarded
        end
      end

      response '404', 'not found' do
        let(:id) { 999999 }
        run_test!
      end
    end
  end
end
