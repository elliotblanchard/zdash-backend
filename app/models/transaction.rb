class Transaction < ApplicationRecord
  validates :zhash, presence: true
  validates :zhash, uniqueness: true 
end