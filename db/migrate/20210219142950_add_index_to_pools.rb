class AddIndexToPools < ActiveRecord::Migration[6.0]
  def change
    add_index :pools, :timestamp
  end
end
