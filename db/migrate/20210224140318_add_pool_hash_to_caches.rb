class AddPoolHashToCaches < ActiveRecord::Migration[6.0]
  def change
    add_column :caches, :pool_hash, :hstore
  end
end
