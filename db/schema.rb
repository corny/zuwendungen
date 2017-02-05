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

ActiveRecord::Schema.define(version: 20170205135452) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "donations", force: :cascade do |t|
    t.date    "date_begin",                          null: false
    t.date    "date_end",                            null: false
    t.string  "state",                               null: false
    t.string  "number"
    t.string  "donor",                               null: false
    t.string  "recipient",                           null: false
    t.string  "kind",                                null: false
    t.string  "purpose",                             null: false
    t.decimal "amount",     precision: 13, scale: 2, null: false
    t.index ["date_begin", "date_end", "state"], name: "index_donations_on_date_begin_and_date_end_and_state", using: :btree
    t.index ["donor"], name: "index_donations_on_donor", using: :btree
    t.index ["purpose"], name: "index_donations_on_purpose", using: :btree
    t.index ["recipient"], name: "index_donations_on_recipient", using: :btree
    t.index ["state", "number"], name: "index_donations_on_state_and_number", unique: true, using: :btree
  end

end
