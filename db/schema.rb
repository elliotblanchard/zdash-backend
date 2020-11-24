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

ActiveRecord::Schema.define(version: 2020_11_24_192123) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "transactions", force: :cascade do |t|
    t.string "zhash"
    t.boolean "mainChain"
    t.decimal "fee"
    t.string "type"
    t.boolean "shielded"
    t.integer "index"
    t.string "blockHash"
    t.integer "blockHeight"
    t.integer "version"
    t.integer "lockTime"
    t.integer "timestamp"
    t.integer "time"
    t.text "vin"
    t.text "vout"
    t.text "vjoinsplit"
    t.decimal "vShieldedOutput"
    t.decimal "vShieldedSpend"
    t.decimal "valueBalance"
    t.decimal "value"
    t.decimal "outputValue"
    t.decimal "shieldedValue"
    t.boolean "overwintered"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
