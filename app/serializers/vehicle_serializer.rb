class VehicleSerializer
  include Alba::Resource

  root_key :vehicle, :vehicles

  attributes :id, :vin, :plate, :brand, :model, :year, :status, :created_at, :updated_at
end
