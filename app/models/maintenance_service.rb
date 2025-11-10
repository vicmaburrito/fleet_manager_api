class MaintenanceService < ApplicationRecord
  include AASM

  SORTABLE_FIELDS = [ :id, :date, :cost_cents, :priority, :status, :created_at ].freeze

  belongs_to :vehicle
  enum :priority, { low: "low", medium: "medium", high: "high" }

  validates :description, presence: true
  validates :date, presence: true
  validates :cost_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :date_cannot_be_in_future
  validate :completed_at_required_when_completed

  aasm column: :status do
    state :pending, initial: true
    state :in_progress
    state :completed

    event :start do
      transitions from: :pending, to: :in_progress
      after do
        vehicle.start_maintenance! if vehicle.may_start_maintenance?
      end
    end

    event :complete do
      transitions from: [ :pending, :in_progress ], to: :completed
      before do
        self.completed_at = Time.current if completed_at.blank?
      end
      after do
        update_vehicle_status
      end
    end

    event :reopen do
      transitions from: [ :in_progress, :completed ], to: :pending
      after do
        vehicle.start_maintenance! if vehicle.may_start_maintenance?
      end
    end
  end

  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_priority, ->(priority) { where(priority: priority) if priority.present? }
  scope :by_vehicle_id, ->(vehicle_id) { where(vehicle_id: vehicle_id) if vehicle_id.present? }
  scope :between_dates, ->(from, to) {
    scope = all
    scope = scope.where("date >= ?", from) if from.present?
    scope = scope.where("date <= ?", to) if to.present?
    scope
  }
  scope :pending_or_in_progress, -> { where(status: [ :pending, :in_progress ]) }
  scope :search, ->(query) {
    return all if query.blank?
    where("description ILIKE ?", "%#{query}%")
  }

  after_save :sync_vehicle_status
  after_destroy :sync_vehicle_status

  def self.filterable_attributes
    %w[status priority vehicle_id]
  end

  private

  def date_cannot_be_in_future
    return unless date.present? && date > Date.current
    errors.add(:date, "cannot be in the future")
  end

  def completed_at_required_when_completed
    return unless status == "completed" && completed_at.blank?
    errors.add(:completed_at, "is required when status is completed")
  end

  def sync_vehicle_status
    return unless vehicle

    if vehicle.maintenance_services.pending_or_in_progress.any?
      vehicle.start_maintenance! if vehicle.may_start_maintenance?
    else
      vehicle.finish_maintenance! if vehicle.may_finish_maintenance?
    end
  end

  def update_vehicle_status
    return unless vehicle

    if vehicle.maintenance_services.pending_or_in_progress.none?
      vehicle.finish_maintenance! if vehicle.may_finish_maintenance?
    end
  end
end
