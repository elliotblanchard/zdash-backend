class AddIndexToTransactions < ActiveRecord::Migration[6.0]
  def change
    add_index :transactions, :timestamp
  end
end
