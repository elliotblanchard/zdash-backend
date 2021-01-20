class Cache < ApplicationRecord

  validates :timestamp_start, presence: true
  validates :timestamp_end, presence: true
  validates :total, presence: true
  validates :category_hash, presence: true

end