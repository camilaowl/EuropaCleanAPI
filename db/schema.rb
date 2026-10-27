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

ActiveRecord::Schema[8.1].define(version: 2026_10_27_100806) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "item_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "default_display_name", null: false
    t.string "icon_asset_key"
    t.string "item_type_key", null: false
    t.datetime "updated_at", null: false
    t.index ["item_type_key"], name: "index_item_types_on_item_type_key", unique: true
  end

  create_table "room_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "item_type_id"
    t.string "name"
    t.bigint "room_id", null: false
    t.datetime "updated_at", null: false
    t.index ["item_type_id"], name: "index_room_items_on_item_type_id"
    t.index ["room_id"], name: "index_room_items_on_room_id"
  end

  create_table "room_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "default_display_name", null: false
    t.string "icon_asset_key"
    t.string "room_type_key", null: false
    t.datetime "updated_at", null: false
    t.index ["room_type_key"], name: "index_room_types_on_room_type_key", unique: true
  end

  create_table "rooms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "room_type_id"
    t.bigint "space_id", null: false
    t.datetime "updated_at", null: false
    t.index ["room_type_id"], name: "index_rooms_on_room_type_id"
    t.index ["space_id"], name: "index_rooms_on_space_id"
  end

  create_table "spaces", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "space_type", default: "home", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_spaces_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "jti", null: false
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "room_items", "item_types"
  add_foreign_key "room_items", "rooms"
  add_foreign_key "rooms", "room_types"
  add_foreign_key "rooms", "spaces"
  add_foreign_key "spaces", "users"
end
