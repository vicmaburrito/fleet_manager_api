class VehicleContract < Dry::Validation::Contract
  params do
    required(:vin).filled(:string)
    required(:plate).filled(:string)
    required(:brand).filled(:string)
    required(:model).filled(:string)
    required(:year).filled(:integer)
    optional(:status).filled(:string, included_in?: %w[active inactive in_maintenance])
  end

  rule(:year) do
    if value < 1990 || value > 2050
      key.failure("must be between 1990 and 2050")
    end
  end

  rule(:vin) do
    if key? && value.present?
      existing = Vehicle.find_by(vin: value)
      if existing && existing.id != context[:vehicle_id]
        key.failure("has already been taken")
      end
    end
  end

  rule(:plate) do
    if key? && value.present?
      existing = Vehicle.find_by(plate: value)
      if existing && existing.id != context[:vehicle_id]
        key.failure("has already been taken")
      end
    end
  end
end
