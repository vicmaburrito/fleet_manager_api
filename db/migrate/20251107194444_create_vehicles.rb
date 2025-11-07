class CreateVehicles < ActiveRecord::Migration[7.2]
  def change
    create_table :vehicles do |t|
      t.citext :vin, null: false
      t.citext :plate, null: false
      t.string :brand, null: false
      t.string :model, null: false
      t.integer :year, null: false
      t.string :status, null: false, default: "active"
      t.timestamps
    end

    add_index :vehicles, :vin, unique: true
    add_index :vehicles, :plate, unique: true
    add_index :vehicles, :status
    add_index :vehicles, :year

    add_check_constraint :vehicles,
      "year >= 1990 AND year <= 2050",
      name: "valid_year_range"
  end
end
