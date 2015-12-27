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

ActiveRecord::Schema.define(version: 20151225073812) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "block_lists", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blocks", force: :cascade do |t|
    t.text     "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reports", force: :cascade do |t|
    t.text     "text"
    t.integer  "block_list_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "reports", ["block_list_id"], name: "index_reports_on_block_list_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "display_name"
    t.string   "account_created"
    t.boolean  "default_profile_image"
    t.text     "description"
    t.integer  "incoming_follows"
    t.integer  "outgoing_follows"
    t.string   "account_id"
    t.string   "profile_image_url"
    t.string   "user_name"
    t.string   "website"
    t.integer  "posts"
    t.integer  "times_reported",        default: 0
    t.integer  "times_blocked",         default: 0
    t.integer  "reports",               default: 0
    t.integer  "blocks",                default: 0
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_foreign_key "reports", "block_lists"
end
