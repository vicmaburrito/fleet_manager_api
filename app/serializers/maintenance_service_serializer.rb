class MaintenanceServiceSerializer
  include Alba::Resource

  root_key :maintenance_service, :maintenance_services

  attributes :id, :vehicle_id, :description, :status, :date,
             :cost_cents, :priority, :completed_at, :created_at, :updated_at

  one :vehicle, resource: VehicleSerializer

  attribute :cost_formatted do |service|
    "$%.2f" % (service.cost_cents / 100.0)
  end
end
