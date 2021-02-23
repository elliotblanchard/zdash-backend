class Pool < ApplicationRecord

  validates :blockHeight, presence: true
  validates :timestamp, presence: true
  validates :sprout, presence: true
  validates :sproutHidden, presence: true
  validates :sproutRevealed, presence: true
  validates :sproutPool, presence: true
  validates :sapling, presence: true 
  validates :saplingHidden, presence: true
  validates :saplingRevealed, presence: true
  validates :saplingPool, presence: true

end