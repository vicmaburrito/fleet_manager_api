class Api::V1::VehiclesController < Api::V1::Auth::BaseController
  before_action :authenticate_user!
  before_action :set_vehicle, only: [ :show, :update, :destroy ]

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def index
    @pagy, vehicles = pagy(vehicles_scope, items: params[:per_page] || 20)
    render json: VehicleSerializer.new(vehicles)
  end

  def show
    render json: VehicleSerializer.new(@vehicle)
  end

  def create
    contract_result = VehicleContract.new.call(vehicle_params.to_h)

    if contract_result.failure?
      return render json: {
        error: {
          code: "validation_failed",
          message: "Validation failed",
          details: format_contract_errors(contract_result.errors)
        }
      }, status: :unprocessable_content
    end

    @vehicle = Vehicle.new(contract_result.to_h)

    if @vehicle.save
      render json: VehicleSerializer.new(@vehicle), status: :created
    else
      render_validation_errors(@vehicle)
    end
  end

  def update
    if @vehicle.update(vehicle_params)
      render json: VehicleSerializer.new(@vehicle)
    else
      render_validation_errors(@vehicle)
    end
  end

  def destroy
    @vehicle.destroy!
    head :no_content
  end

  private

  def set_vehicle
    @vehicle = Vehicle.find(params[:id])
  end

  def vehicle_params
    params.require(:vehicle).permit(:vin, :plate, :brand, :model, :year, :status)
  end

  def vehicles_scope
    Vehicle
      .then { |scope| filter_scope(scope) }
      .search(params[:q])
      .then { |scope| sort_scope(scope) }
  end

  def filter_scope(scope)
    Vehicle.filterable_attributes.each do |attr|
      scope = scope.public_send("by_#{attr}", params[attr]) if params[attr].present?
    end
    scope
  end

  def sort_scope(scope)
    return scope.order(created_at: :desc) unless params[:sort_by].present?

    sort_by = params[:sort_by].to_sym
    sort_order = params[:sort_order]&.downcase == "desc" ? :desc : :asc

    if Vehicle::SORTABLE_FIELDS.include?(sort_by)
      scope.order(sort_by => sort_order)
    else
      scope.order(created_at: :desc)
    end
  end

  def format_contract_errors(errors)
    errors.to_h.transform_values { |messages| messages }
  end

  def render_validation_errors(resource)
    render json: {
      error: {
        code: "validation_failed",
        message: "Validation failed",
        details: resource.errors.messages
      }
    }, status: :unprocessable_content
  end

  def not_found
    render json: {
      error: {
        code: "not_found",
        message: "Vehicle not found"
      }
    }, status: :not_found
  end
end
