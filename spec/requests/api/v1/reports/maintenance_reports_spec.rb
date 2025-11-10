require 'swagger_helper'

RSpec.describe 'API::V1::Reports::MaintenanceReports', type: :request do
  let(:user) { create(:user) }
  let(:Authorization) { "Bearer fake-token" }

  before do
    allow_any_instance_of(Api::V1::Auth::BaseController)
      .to receive(:current_user)
      .and_return(user)
  end

  let!(:vehicle1) { create(:vehicle, plate: 'AAA111') }
  let!(:vehicle2) { create(:vehicle, plate: 'BBB222') }
  let!(:vehicle3) { create(:vehicle, plate: 'CCC333') }

  let!(:service1) { create(:maintenance_service, :completed, vehicle: vehicle1, cost_cents: 10000, date: 1.month.ago) }
  let!(:service2) { create(:maintenance_service, :pending, vehicle: vehicle1, cost_cents: 50000, date: 2.months.ago) }
  let!(:service3) { create(:maintenance_service, :in_progress, vehicle: vehicle2, cost_cents: 2000, date: 1.week.ago) }
  let!(:service4) { create(:maintenance_service, :completed, vehicle: vehicle3, cost_cents: 30000, date: 1.month.ago) }

  path '/api/v1/reports/maintenance_reports' do
    post 'Crea un reporte de resumen de mantenimiento' do
      tags 'Reports'
      security [ bearerAuth: [] ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :report_params, in: :body, schema: {
        type: :object,
        properties: {
          from: {
            type: :string,
            format: :date,
            description: 'Fecha de inicio del reporte (YYYY-MM-DD)',
            example: '2024-08-01'
          },
          to: {
            type: :string,
            format: :date,
            description: 'Fecha de fin del reporte (YYYY-MM-DD)',
            example: '2024-11-10'
          }
        }
      }

      response '201', 'Reporte de mantenimiento creado exitosamente (JSON)' do
        let(:report_params) {
          {
            from: 3.months.ago.to_date.to_s,
            to: Date.current.to_s
          }
        }

        schema type: :object,
          properties: {
            total_orders: {
              type: :integer,
              example: 4,
              description: 'Número total de órdenes de mantenimiento en el período.'
            },
            total_cost_cents: {
              type: :integer,
              example: 92000,
              description: 'Costo total acumulado en centavos.'
            },
            cost_by_status: {
              type: :object,
              additionalProperties: { type: :integer },
              example: {
                pending: 50000,
                completed: 40000,
                in_progress: 2000
              },
              description: 'Desglose del costo total por estado del servicio.'
            },
            top_3_vehicles_by_cost: {
              type: :object,
              additionalProperties: { type: :integer },
              example: {
                "AAA111": 60000,
                "CCC333": 30000,
                "BBB222": 2000
              },
              description: 'Los 3 vehículos con mayor costo de mantenimiento en el período.'
            },
            breakdown_by_vehicle: {
              type: :object,
              additionalProperties: { type: :integer },
              description: 'Desglose detallado del costo por cada vehículo en el período.'
            }
          },
          required: [ 'total_orders', 'total_cost_cents', 'cost_by_status', 'top_3_vehicles_by_cost', 'breakdown_by_vehicle' ]

        run_test! do |response|
          json = JSON.parse(response.body, symbolize_names: true)

          expect(json[:total_orders]).to eq(4)
          expect(json[:total_cost_cents]).to eq(92000)

          expect(json[:cost_by_status]).to be_a(Hash)
          expect(json[:cost_by_status].keys.map(&:to_sym)).to match_array([ :pending, :completed, :in_progress ])

          expect(json[:top_3_vehicles_by_cost]).to be_a(Hash)
          expect(json[:top_3_vehicles_by_cost].size).to be <= 3

          costs = json[:top_3_vehicles_by_cost].values
          expect(costs).to eq(costs.sort.reverse)

          expect(json[:breakdown_by_vehicle]).to be_a(Hash)
          expect(json[:breakdown_by_vehicle].keys).to include(:AAA111, :BBB222, :CCC333)
        end
      end

      response '201', 'Reporte con rango de fechas limitado' do
        let(:report_params) {
          {
            from: 1.month.ago.to_date.to_s,
            to: Date.current.to_s
          }
        }

        run_test! do |response|
          json = JSON.parse(response.body, symbolize_names: true)

          expect(json[:total_orders]).to eq(3)
          expect(json[:total_cost_cents]).to eq(42000)
        end
      end

      response '201', 'Reporte sin servicios en el rango de fechas' do
        let(:report_params) {
          {
            from: 2.years.ago.to_date.to_s,
            to: 1.year.ago.to_date.to_s
          }
        }

        run_test! do |response|
          json = JSON.parse(response.body, symbolize_names: true)

          expect(json[:total_orders]).to eq(0)
          expect(json[:total_cost_cents]).to eq(0)
          expect(json[:cost_by_status]).to be_empty
          expect(json[:top_3_vehicles_by_cost]).to be_empty
          expect(json[:breakdown_by_vehicle]).to be_empty
        end
      end

      response '422', 'Error al generar el reporte' do
        let(:report_params) { { from: 'invalid-date', to: 'invalid-date' } }

        before do
          allow(MaintenanceSummaryService).to receive(:call).and_return(
            double(success?: false, report: nil)
          )
        end

        schema type: :object,
          properties: {
            error: {
              type: :object,
              properties: {
                message: { type: :string, example: 'Report generation failed' }
              }
            }
          }

        run_test! do |response|
          json = JSON.parse(response.body, symbolize_names: true)
          expect(json[:error][:message]).to eq('Report generation failed')
        end
      end

      response '401', 'No autorizado - token inválido o ausente' do
        let(:Authorization) { nil }
        let(:report_params) {
          {
            from: 1.month.ago.to_date.to_s,
            to: Date.current.to_s
          }
        }

        before do
          allow_any_instance_of(Api::V1::Auth::BaseController)
            .to receive(:current_user)
            .and_return(nil)
        end

        run_test!
      end
    end
  end

  path '/api/v1/reports/maintenance_reports.csv' do
    post 'Exporta reporte de mantenimiento en formato CSV' do
      tags 'Reports'
      security [ bearerAuth: [] ]
      consumes 'application/json'
      produces 'text/csv'

      parameter name: :report_params, in: :body, schema: {
        type: :object,
        properties: {
          from: {
            type: :string,
            format: :date,
            description: 'Fecha de inicio del reporte (YYYY-MM-DD)',
            example: '2024-08-01'
          },
          to: {
            type: :string,
            format: :date,
            description: 'Fecha de fin del reporte (YYYY-MM-DD)',
            example: '2024-11-10'
          }
        }
      }

      response '200', 'Reporte exportado exitosamente en formato CSV' do
        let(:report_params) {
          {
            from: 3.months.ago.to_date.to_s,
            to: Date.current.to_s
          }
        }

        before do |example|
          example.metadata[:headers] = { 'Accept' => 'text/csv' }
        end

        schema type: :string,
          description: 'Archivo CSV con el resumen de mantenimiento',
          example: "Resumen de Mantenimiento,\nTotal de Órdenes:,4\nCosto Total (cents):,92000\n\nDesglose por Status,Costo (cents)\nPending,50000\nCompleted,40000\n"

        run_test! do |response|
          expect(response.content_type).to match(/text\/csv/)

          csv_body = response.body
          expect(csv_body).to include('Resumen de Mantenimiento')
          expect(csv_body).to include('Total de Órdenes:,4')
          expect(csv_body).to include('Costo Total (cents):,92000')
          expect(csv_body).to include('Desglose por Status')
          expect(csv_body).to include('Top 3 Vehículos por Costo')

          expect(csv_body).to match(/AAA111|BBB222|CCC333/)
        end
      end
    end
  end
end
