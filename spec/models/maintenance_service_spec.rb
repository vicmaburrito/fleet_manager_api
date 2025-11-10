require 'rails_helper'

RSpec.describe MaintenanceService, type: :model do
  describe 'associations' do
    it { should belong_to(:vehicle) }
  end

  describe 'validations' do
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:cost_cents) }
    it { should validate_numericality_of(:cost_cents).only_integer.is_greater_than_or_equal_to(0) }
  end

  describe 'scopes' do
    let!(:vehicle) { create(:vehicle) }
    let!(:pending_service) { create(:maintenance_service, :pending, vehicle: vehicle) }
    let!(:completed_service) { create(:maintenance_service, :completed, vehicle: vehicle) }
    let!(:high_priority) { create(:maintenance_service, :high_priority, vehicle: vehicle) }

    describe '.by_status' do
      it 'filters by status' do
        expect(MaintenanceService.by_status('pending')).to include(pending_service)
        expect(MaintenanceService.by_status('pending')).not_to include(completed_service)
      end
    end

    describe '.by_priority' do
      it 'filters by priority' do
        expect(MaintenanceService.by_priority('high')).to include(high_priority)
      end
    end

    describe '.pending_or_in_progress' do
      it 'returns pending and in_progress services' do
        expect(MaintenanceService.pending_or_in_progress).to include(pending_service)
        expect(MaintenanceService.pending_or_in_progress).not_to include(completed_service)
      end
    end
  end

  describe 'custom validations' do
    describe '#date_cannot_be_in_future' do
      it 'is invalid when date is in the future' do
        service = build(:maintenance_service, date: 1.day.from_now)
        expect(service).not_to be_valid
        expect(service.errors[:date]).to include('cannot be in the future')
      end

      it 'is valid when date is today or in the past' do
        service = build(:maintenance_service, date: Date.current)
        expect(service).to be_valid
      end
    end

    describe '#completed_at_required_when_completed' do
      it 'is invalid when completed without completed_at' do
        service = build(:maintenance_service, status: :completed, completed_at: nil)
        expect(service).not_to be_valid
        expect(service.errors[:completed_at]).to include('is required when status is completed')
      end

      it 'is valid when completed with completed_at' do
        service = build(:maintenance_service, :completed)
        expect(service).to be_valid
      end
    end
  end

  describe 'AASM states and events' do
    let(:service) { create(:maintenance_service, :pending) }

    it 'starts in pending state' do
      expect(service).to be_pending
    end

    describe '#start' do
      it 'transitions from pending to in_progress' do
        expect { service.start! }.to change { service.status }.from('pending').to('in_progress')
      end
    end

    describe '#complete' do
      it 'transitions to completed and sets completed_at' do
        service.complete!
        expect(service).to be_completed
        expect(service.completed_at).to be_present
      end
    end
  end

  describe 'vehicle status sync' do
    let(:vehicle) { create(:vehicle, status: :active) }
    let!(:service) { create(:maintenance_service, :pending, vehicle: vehicle) }

    it 'changes vehicle status to in_maintenance when service is pending' do
      vehicle.reload
      expect(vehicle).to be_in_maintenance
    end

    it 'changes vehicle status to active when all services are completed' do
      service.complete!
      vehicle.reload
      expect(vehicle).to be_active
    end
  end

  describe 'Soft Delete with Discard' do
    let!(:service) { create(:maintenance_service) }
    it 'soft deletes the record when discard is called' do
      expect(service).to be_kept
      expect { service.discard }.to change { service.reload.discarded_at }.from(nil).to(be_present)
      expect(MaintenanceService.kept).not_to include(service)
      expect(MaintenanceService.discarded).to include(service)
    end

    it 'can be restored' do
      service.discard
      expect { service.undiscard }.to change { service.reload.discarded_at }.from(be_present).to(nil)
      expect(MaintenanceService.kept).to include(service)
    end
  end
end
