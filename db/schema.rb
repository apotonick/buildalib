# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_10_160223) do

  create_table "reset_password_keys", force: :cascade do |t|
    t.integer "user_id"
    t.text "key"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["key"], name: "index_reset_password_keys_on_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.text "email"
    t.text "state"
    t.text "password"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "verify_account_keys", force: :cascade do |t|
    t.integer "user_id"
    t.text "key"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["key"], name: "index_verify_account_keys_on_key", unique: true
  end

end
