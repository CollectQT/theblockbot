# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160125045946) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "auths", force: :cascade do |t|
    t.string   "encrypted_token"
    t.string   "encrypted_secret"
    t.integer  "user_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "auths", ["user_id"], name: "index_auths_on_user_id", using: :btree

  create_table "block_lists", force: :cascade do |t|
    t.string   "name",                        null: false
    t.boolean  "hidden",      default: false, null: false
    t.boolean  "show_blocks", default: true,  null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "block_lists", ["name"], name: "index_block_lists_on_name", unique: true, using: :btree

  create_table "blockers", force: :cascade do |t|
    t.string   "type"
    t.integer  "user_id"
    t.integer  "block_list_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "blockers", ["block_list_id"], name: "index_blockers_on_block_list_id", using: :btree
  add_index "blockers", ["user_id"], name: "index_blockers_on_user_id", using: :btree

  create_table "blocks", force: :cascade do |t|
    t.text     "text"
    t.integer  "user_id",    null: false
    t.integer  "report_id"
    t.integer  "target_id",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "blocks", ["report_id"], name: "index_blocks_on_report_id", using: :btree
  add_index "blocks", ["target_id"], name: "index_blocks_on_target_id", using: :btree
  add_index "blocks", ["user_id"], name: "index_blocks_on_user_id", using: :btree

  create_table "reports", force: :cascade do |t|
    t.text     "text"
    t.boolean  "processed",     default: false, null: false
    t.integer  "target_id",                     null: false
    t.integer  "reporter_id",                   null: false
    t.integer  "approver_id"
    t.integer  "block_list_id",                 null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "reports", ["approver_id"], name: "index_reports_on_approver_id", using: :btree
  add_index "reports", ["block_list_id"], name: "index_reports_on_block_list_id", using: :btree
  add_index "reports", ["processed"], name: "index_reports_on_processed", using: :btree
  add_index "reports", ["reporter_id"], name: "index_reports_on_reporter_id", using: :btree
  add_index "reports", ["target_id"], name: "index_reports_on_target_id", using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id",       null: false
    t.integer  "block_list_id", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "subscriptions", ["block_list_id"], name: "index_subscriptions_on_block_list_id", using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "account_created"
    t.boolean  "default_profile_image"
    t.text     "description"
    t.integer  "incoming_follows"
    t.integer  "outgoing_follows"
    t.string   "account_id"
    t.string   "profile_image_url"
    t.string   "user_name"
    t.string   "website"
    t.string   "url"
    t.integer  "posts"
    t.integer  "times_reported",        default: 0
    t.integer  "times_blocked",         default: 0
    t.integer  "reports_created",       default: 0
    t.integer  "reports_approved",      default: 0
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "users", ["account_id", "website"], name: "index_users_on_account_id_and_website", unique: true, using: :btree

  add_foreign_key "auths", "users"
  add_foreign_key "blockers", "block_lists"
  add_foreign_key "blockers", "users"
  add_foreign_key "blocks", "reports"
  add_foreign_key "blocks", "users"
  add_foreign_key "reports", "block_lists"
  add_foreign_key "subscriptions", "block_lists"
  add_foreign_key "subscriptions", "users"
end
