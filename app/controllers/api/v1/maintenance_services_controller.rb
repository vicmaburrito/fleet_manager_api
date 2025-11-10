class Api::V1::MaintenanceServicesController < Api::V1::Auth::BaseController
  before_action :authenticate_user!
  before_action :set_vehicle, only: [ :index, :create ]
  before_action :set_maintenance_service, only: [ :show, :update, :destroy ]

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def index
    @pagy, services = pagy(services_scope, items: params[:per_page] || 20)
    render json: MaintenanceServiceSerializer.new(services)
  end

  def show
    render json: MaintenanceServiceSerializer.new(@maintenance_service)
  end

  def create
    contract_result = MaintenanceServiceContract.new.call(
      maintenance_service_params.to_h
    )

    if contract_result.failure?
      return render json: {
        error: {
          code: "validation_failed",
          message: "Validation failed",
          details: format_contract_errors(contract_result.errors)
        }
      }, status: :unprocessable_content
    end

    @maintenance_service = @vehicle.maintenance_services.build(contract_result.to_h)

    if @maintenance_service.save
      render json: MaintenanceServiceSerializer.new(@maintenance_service), status: :created
    else
      render_validation_errors(@maintenance_service)
    end
  end

  def update
    if @maintenance_service.update(maintenance_service_params)
      render json: MaintenanceServiceSerializer.new(@maintenance_service)
    else
      render_validation_errors(@maintenance_service)
    end
  end

  def destroy
    @maintenance_service.destroy!
    head :no_content
  end

  private

  def set_vehicle
    @vehicle = Vehicle.find(params[:vehicle_id])
  end

  def set_maintenance_service
    @maintenance_service = MaintenanceService.find(params[:id])
  end

  def maintenance_service_params
    params.require(:maintenance_service).permit(
      :description, :status, :date, :cost_cents, :priority, :completed_at
    )
  end

  def services_scope
    scope = @vehicle ? @vehicle.maintenance_services : MaintenanceService.all

    scope
      .includes(:vehicle)
      .then { |s| filter_scope(s) }
      .search(params[:q])
      .then { |s| date_filter_scope(s) }
      .then { |s| sort_scope(s) }
  end

  def filter_scope(scope)
    MaintenanceService.filterable_attributes.each do |attr|
      scope = scope.public_send("by_#{attr}", params[attr]) if params[attr].present?
    end
    scope
  end

  def date_filter_scope(scope)
    scope.between_dates(params[:from], params[:to])
  end

  def sort_scope(scope)
    return scope.order(date: :desc) unless params[:sort_by].present?

    sort_by = params[:sort_by].to_sym
    sort_order = params[:sort_order]&.downcase == "desc" ? :desc : :asc

    if MaintenanceService::SORTABLE_FIELDS.include?(sort_by)
      scope.order(sort_by => sort_order)
    else
      scope.order(date: :desc)
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
        message: "Resource not found"
      }
    }, status: :not_found
  end
end
