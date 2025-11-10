class MaintenanceServiceContract < Dry::Validation::Contract
  params do
    required(:description).filled(:string)
    required(:date).filled(:date)
    required(:cost_cents).filled(:integer)
    optional(:status).filled(:string, included_in?: %w[pending in_progress completed])
    optional(:priority).filled(:string, included_in?: %w[low medium high])
    optional(:completed_at).maybe(:date_time)
  end

  rule(:cost_cents) do
    key.failure("must be greater than or equal to 0") if value && value.negative?
  end

  rule(:date) do
    key.failure("cannot be in the future") if value && value > Date.current
  end

  rule(:status, :completed_at) do
    if values[:status] == "completed" && values[:completed_at].blank?
      key(:completed_at).failure("is required when status is completed")
    end
  end

  rule(:completed_at, :date) do
    if values[:completed_at].present? && values[:date].present?
      completed_date = values[:completed_at].to_date
      service_date = values[:date]

      if completed_date < service_date
        key(:completed_at).failure("cannot be before service date")
      end
    end
  end
end
