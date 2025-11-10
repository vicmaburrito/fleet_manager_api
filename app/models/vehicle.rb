class Vehicle < ApplicationRecord
  include AASM

  SORTABLE_FIELDS = [ :id, :vin, :plate, :brand, :model, :year, :status, :created_at ].freeze

  # has_many :maintenance_services, dependent: :destroy

  validates :vin, presence: true, uniqueness: { case_sensitive: false }
  validates :plate, presence: true, uniqueness: { case_sensitive: false }
  validates :brand, :model, presence: true
  validates :year, presence: true,
                   numericality: {
                     only_integer: true,
                     greater_than_or_equal_to: 1990,
                     less_than_or_equal_to: 2050
                   }

  aasm column: :status do
    state :active, initial: true
    state :inactive
    state :in_maintenance

    event :deactivate do
      transitions from: [ :active, :in_maintenance ], to: :inactive
    end

    event :activate do
      transitions from: [ :inactive, :in_maintenance ], to: :active
    end

    event :start_maintenance do
      transitions from: [ :active, :inactive ], to: :in_maintenance
    end

    event :finish_maintenance do
      transitions from: :in_maintenance, to: :active
    end
  end

  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_brand, ->(brand) { where(brand: brand) if brand.present? }
  scope :by_year, ->(year) { where(year: year) if year.present? }
  scope :search, ->(query) {
    return all if query.blank?

    where("vin LIKE :q OR plate LIKE :q OR brand LIKE :q OR model LIKE :q", q: "%#{query}%")
  }

  def self.filterable_attributes
    %w[status brand year]
  end
end
