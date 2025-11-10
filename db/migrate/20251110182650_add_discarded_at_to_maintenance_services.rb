class AddDiscardedAtToMaintenanceServices < ActiveRecord::Migration[7.2]
  def change
    add_column :maintenance_services, :discarded_at, :datetime
    add_index :maintenance_services, :discarded_at
  end
end
