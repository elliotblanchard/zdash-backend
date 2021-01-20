class CreateCaches < ActiveRecord::Migration[6.0]
  def change
    create_table :caches do |t|
      enable_extension 'hstore' unless extension_enabled?('hstore')
      t.integer :timestamp_start
      t.integer :timestamp_end
      t.integer :total
      t.hstore :category_hash
      t.timestamps
    end
  end
end
