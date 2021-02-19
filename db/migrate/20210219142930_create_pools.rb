class CreatePools < ActiveRecord::Migration[6.0]
  def change
    create_table :pools do |t|
      t.integer :blockHeight
      t.integer :timestamp
      t.integer :sprout
      t.decimal :sproutHidden
      t.decimal :sproutRevealed
      t.decimal :sproutPool
      t.integer :sapling
      t.decimal :saplingHidden
      t.decimal :saplingRevealed
      t.decimal :saplingPool

      t.timestamps
    end
  end
end
