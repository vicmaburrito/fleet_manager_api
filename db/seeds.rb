require 'faker'

User.find_or_create_by!(email: "admin@flota.com") do |user|
  user.password = "password123"
end

vehicles = Array.new(10) do
  Vehicle.create!(
    vin: Faker::Vehicle.unique.vin,
    plate: Faker::Alphanumeric.alphanumeric(number: 7).upcase,
    brand: Faker::Vehicle.make,
    model: Faker::Vehicle.model,
    year: rand(2010..2024),
    status: Vehicle.aasm.states.map { |s| s.name.to_s }.sample
  )
end

30.times do
  vehicle = vehicles.sample

  status = MaintenanceService.aasm.states.map { |s| s.name.to_s }.sample
  priority = MaintenanceService.priorities.keys.sample
  date = Faker::Date.backward(days: 365)

  service = MaintenanceService.create!(
    vehicle: vehicle,
    description: Faker::Lorem.sentence(word_count: 6),
    status: status,
    priority: priority,
    cost_cents: rand(5_000..250_000),
    date: date,
    completed_at: (Time.zone.now if status == "completed")
  )

  service.discard! if rand(15).zero?
end
