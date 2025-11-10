class Api::V1::Reports::MaintenanceReportsController < Api::V1::Auth::BaseController
  before_action :authenticate_user!

  def create
    report = MaintenanceSummaryService.call(from: params[:from], to: params[:to])

    if report.success?
      report_data = report.report

      if csv_requested?
        send_data report_data[:csv_export],
                  filename: "maintenance_summary_#{Time.zone.now.to_i}.csv",
                  type: "text/csv",
                  disposition: "attachment"
      else
        render json: report_data.except(:csv_export), status: :created
      end
    else
      render json: { error: { message: "Report generation failed" } }, status: :unprocessable_entity
    end
  end

  private

  def csv_requested?
    request.format.csv? || request.headers["Accept"]&.include?("text/csv")
  end
end
