require "swagger_helper"

RSpec.describe 'API::V1::MaintenanceServices', type: :request do
  let(:user) { build(:user) }
  let(:Authorization) { "Bearer fake-token" }
  let(:vehicle) { create(:vehicle) }

  before do
    allow_any_instance_of(Api::V1::Auth::BaseController)
      .to receive(:current_user)
      .and_return(user)
  end

  path '/api/v1/vehicles/{vehicle_id}/maintenance_services' do
    parameter name: :vehicle_id, in: :path, type: :integer

    get 'List maintenance services for a vehicle' do
      tags 'Maintenance Services'
      produces 'application/json'
      security [ bearerAuth: [] ]

      response '200', 'successful' do
        let(:vehicle_id) { vehicle.id }
        before { create_list(:maintenance_service, 3, vehicle: vehicle) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['maintenance_services']).to be_present
          expect(data['maintenance_services'].length).to eq(3)
        end
      end

      response '404', 'vehicle not found' do
        let(:vehicle_id) { 999999 }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:vehicle_id) { vehicle.id }
        let(:Authorization) { nil }
        before do
          allow_any_instance_of(Api::V1::Auth::BaseController)
            .to receive(:current_user)
            .and_return(nil)
        end

        run_test!
      end
    end

    post 'Create maintenance service' do
      tags 'Maintenance Services'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :maintenance_service_params, in: :body, schema: {
        type: :object,
        properties: {
          maintenance_service: {
            type: :object,
            properties: {
              description: { type: :string, example: 'Oil change' },
              date: { type: :string, format: :date, example: '2025-11-09' },
              cost_cents: { type: :integer, example: 5000 },
              status: { type: :string, example: 'pending' },
              priority: { type: :string, example: 'low' }
            },
            required: %w[description date cost_cents]
          }
        }
      }

      response '201', 'created' do
        let(:vehicle_id) { vehicle.id }
        let(:maintenance_service_params) {
          { maintenance_service: attributes_for(:maintenance_service) }
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['maintenance_service']).to be_present
          expect(data['maintenance_service']['description']).to be_present
        end
      end

      response '422', 'validation failed' do
        let(:vehicle_id) { vehicle.id }
        let(:maintenance_service_params) {
          { maintenance_service: { description: '', date: '', cost_cents: -100 } }
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to be_present
        end
      end

      response '401', 'unauthorized' do
        let(:vehicle_id) { vehicle.id }
        let(:maintenance_service_params) {
          { maintenance_service: attributes_for(:maintenance_service) }
        }
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

  path '/api/v1/maintenance_services/{id}' do
    parameter name: :id, in: :path, type: :integer

    get 'Show maintenance service' do
      tags 'Maintenance Services'
      produces 'application/json'
      security [ bearerAuth: [] ]

      response '200', 'found' do
        let(:service) { create(:maintenance_service) }
        let(:id) { service.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['maintenance_service']).to be_present
        end
      end

      response '404', 'not found' do
        let(:id) { 999999 }
        run_test!
      end
    end

    patch 'Update maintenance service' do
      tags 'Maintenance Services'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :maintenance_service_params, in: :body, schema: {
        type: :object,
        properties: {
          maintenance_service: {
            type: :object,
            properties: {
              description: { type: :string },
              status: { type: :string },
              priority: { type: :string }
            }
          }
        }
      }

      response '200', 'updated' do
        let(:service) { create(:maintenance_service) }
        let(:id) { service.id }
        let(:maintenance_service_params) {
          { maintenance_service: { description: 'Updated description' } }
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['maintenance_service']['description']).to eq('Updated description')
        end
      end

      response '422', 'invalid params' do
        let(:service) { create(:maintenance_service) }
        let(:id) { service.id }
        let(:maintenance_service_params) {
          { maintenance_service: { date: 1.year.from_now.to_date } }
        }

        run_test!
      end
    end

    delete 'Delete maintenance service' do
      tags 'Maintenance Services'
      security [ bearerAuth: [] ]

      response '204', 'deleted' do
        let(:service) { create(:maintenance_service) }
        let(:id) { service.id }

        run_test! do
          expect(MaintenanceService.kept.exists?(id)).to be_falsey
          expect(MaintenanceService.with_discarded.find(id)).to be_discarded
        end
      end

      response '404', 'not found' do
        let(:id) { 999999 }
        run_test!
      end
    end
  end
end
