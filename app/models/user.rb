class User < ApplicationRecord

  validates :name, presence: true
  validates :address, presence: true
  validates :address, uniqueness: true

end