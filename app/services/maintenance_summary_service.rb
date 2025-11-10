class MaintenanceSummaryService
  include Interactor
  delegate :from, :to, to: :context

  def call
    @services_scope = MaintenanceService.kept.between_dates(from, to)
    total_orders = @services_scope.count
    total_cost_cents = @services_scope.sum(:cost_cents)
    cost_by_status = @services_scope.group(:status).sum(:cost_cents)
    cost_by_vehicle_raw = @services_scope
      .joins(:vehicle)
      .group("vehicles.plate", "vehicles.id")
      .sum(:cost_cents)

    breakdown_by_vehicle = cost_by_vehicle_raw.transform_keys { |plate, _| plate }
    top_vehicles = @services_scope
      .joins(:vehicle)
      .group("vehicles.plate")
      .order("sum_cost_cents DESC")
      .limit(3)
      .sum(:cost_cents)
    csv_data = generate_csv(total_orders, total_cost_cents, cost_by_status, top_vehicles)

    context.report = {
      total_orders: total_orders,
      total_cost_cents: total_cost_cents,
      cost_by_status: cost_by_status,
      top_3_vehicles_by_cost: top_vehicles,
      breakdown_by_vehicle: breakdown_by_vehicle,
      csv_export: csv_data
    }
  end

  private

  def generate_csv(total_orders, total_cost_cents, cost_by_status, top_vehicles)
    require "csv"
    CSV.generate(headers: true) do |csv|
      csv << [ "Resumen de Mantenimiento", "" ]
      csv << [ "Total de Órdenes:", total_orders ]
      csv << [ "Costo Total (cents):", total_cost_cents ]
      csv << []

      csv << [ "Desglose por Status", "Costo (cents)" ]
      cost_by_status.each { |status, cost| csv << [ status.humanize, cost ] }
      csv << []

      csv << [ "Top 3 Vehículos por Costo", "Costo (cents)" ]
      top_vehicles.each { |plate, cost| csv << [ plate, cost ] }
    end
  end
end
