# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_11_10_182650) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  create_table "maintenance_services", force: :cascade do |t|
    t.bigint "vehicle_id", null: false
    t.text "description", null: false
    t.string "status", default: "pending", null: false
    t.date "date", null: false
    t.integer "cost_cents", default: 0, null: false
    t.string "priority", default: "low", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["date"], name: "index_maintenance_services_on_date"
    t.index ["discarded_at"], name: "index_maintenance_services_on_discarded_at"
    t.index ["priority"], name: "index_maintenance_services_on_priority"
    t.index ["status"], name: "index_maintenance_services_on_status"
    t.index ["vehicle_id", "date"], name: "index_maintenance_services_on_vehicle_id_and_date"
    t.index ["vehicle_id", "status"], name: "index_maintenance_services_on_vehicle_id_and_status"
    t.index ["vehicle_id"], name: "index_maintenance_services_on_vehicle_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "vehicles", force: :cascade do |t|
    t.citext "vin", null: false
    t.citext "plate", null: false
    t.string "brand", null: false
    t.string "model", null: false
    t.integer "year", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_vehicles_on_discarded_at"
    t.index ["plate"], name: "index_vehicles_on_plate", unique: true
    t.index ["status"], name: "index_vehicles_on_status"
    t.index ["vin"], name: "index_vehicles_on_vin", unique: true
    t.index ["year"], name: "index_vehicles_on_year"
  end

  add_foreign_key "maintenance_services", "vehicles"
end
