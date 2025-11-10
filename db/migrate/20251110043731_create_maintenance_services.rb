class CreateMaintenanceServices < ActiveRecord::Migration[7.2]
  def change
    create_table :maintenance_services do |t|
      t.references :vehicle, null: false, foreign_key: true, index: true
      t.text :description, null: false
      t.string :status, null: false, default: 'pending'
      t.date :date, null: false
      t.integer :cost_cents, null: false, default: 0
      t.string :priority, null: false, default: 'low'
      t.datetime :completed_at

      t.timestamps
    end

    add_index :maintenance_services, :status
    add_index :maintenance_services, :priority
    add_index :maintenance_services, :date
    add_index :maintenance_services, [  :vehicle_id, :status ]
    add_index :maintenance_services, [  :vehicle_id, :date ]
  end
end
