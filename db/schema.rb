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

ActiveRecord::Schema.define(version: 2021_02_19_142950) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "caches", force: :cascade do |t|
    t.integer "timestamp_start"
    t.integer "timestamp_end"
    t.integer "total"
    t.hstore "category_hash"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "pools", force: :cascade do |t|
    t.integer "blockHeight"
    t.integer "timestamp"
    t.integer "sprout"
    t.decimal "sproutHidden"
    t.decimal "sproutRevealed"
    t.decimal "sproutPool"
    t.integer "sapling"
    t.decimal "saplingHidden"
    t.decimal "saplingRevealed"
    t.decimal "saplingPool"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["timestamp"], name: "index_pools_on_timestamp"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "zhash"
    t.boolean "mainChain"
    t.decimal "fee"
    t.string "ttype"
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
    t.text "vShieldedOutput"
    t.decimal "vShieldedSpend"
    t.decimal "valueBalance"
    t.decimal "value"
    t.decimal "outputValue"
    t.decimal "shieldedValue"
    t.boolean "overwintered"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "category"
    t.index ["timestamp"], name: "index_transactions_on_timestamp"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
