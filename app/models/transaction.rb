class Transaction < ApplicationRecord

  validates :zhash, presence: true
  validates :zhash, uniqueness: true

  def self.classify_all
    transactions = all
    transactions.each do |transaction| 
      category = classify(transaction)

      unless transaction.update(category: category)
        transaction.destroy # Duplicate zhash
      end
    end
  end

  def self.classify_nil
    latest_transactions = []
    transactions = Transaction.where(category: nil)
    transactions.each do |transaction| 
      category = classify(transaction)
      unless transaction.update(category: category)
        transaction.destroy # Duplicate zhash
      end
    end
  end  

  def self.classify(transaction)
    if transaction
      if transaction.vin.length > 2
        parsed = transaction.vin.split(',')
        if ( (parsed[0].length > 18) && (parsed[0].include? 'coinbase'))
          # vin arr contains coinbase field w/address
          # This next if / else is custom to the blockchain
          # due to differences in way zcash-cli (blockchain)
          # and zcha.in API (ongoing) report vShieldedOutput
          # zcash-cli reports it as an array, while zcha.in
          # reports as a float
          if transaction.vShieldedOutput.to_f > 0.0
            'shielded_coinbase'
          else
            'transparent_coinbase'
          end
        else
          if transaction.vout.length > 2
            'transparent'
          else
            if transaction.vjoinsplit.length > 2
              'sprout_shielding'
            else
              'sapling_shielding'
            end
          end
        end
      else
        if transaction.vout.length > 2
          if transaction.vjoinsplit.length > 2
            'sprout_deshielding'
          else
            'sapling_deshielding'
          end
        else
          if transaction.vjoinsplit.length > 2
            if ( transaction.vShieldedOutput && (transaction.vShieldedOutput.to_f > 0.0) ) # Change
              'migration'
            else
              'sprout_shielded'
            end
          else
            'sapling_shielded'
          end
        end
      end
    else
      return nil
    end
  end
end