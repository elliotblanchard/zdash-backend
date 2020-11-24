class Transaction < ApplicationRecord
  validates :zhash, presence: true
end