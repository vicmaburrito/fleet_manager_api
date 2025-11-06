require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_format = :yaml

  config.openapi_specs = {
    'v1/openapi.yaml' => {
      openapi: '3.0.3',
      info: { title: 'Fleet Manager API', version: 'v1', description: 'API documentation for vehicle fleet management system' },
      servers: [
        { url: ENV.fetch("OPENAPI_SERVER_URL", "http://localhost:3000") }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT'
          }
        }
      }
    }
  }
end
