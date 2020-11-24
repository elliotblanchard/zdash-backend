class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.string :zhash
      t.boolean :mainChain
      t.decimal :fee
      t.string :type
      t.boolean :shielded
      t.integer :index
      t.string :blockHash
      t.integer :blockHeight
      t.integer :version
      t.integer :lockTime
      t.integer :timestamp
      t.integer :time
      t.text :vin
      t.text :vout
      t.text :vjoinsplit
      t.decimal :vShieldedOutput
      t.decimal :vShieldedSpend
      t.decimal :valueBalance
      t.decimal :value
      t.decimal :outputValue
      t.decimal :shieldedValue
      t.boolean :overwintered

      t.timestamps
    end
  end
end
