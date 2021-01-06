class Transaction < ApplicationRecord

  validates :zhash, presence: true
  validates :zhash, uniqueness: true 

  def self.classify_all
    transactions = all
    transactions.each do |transaction| 
      category = classify(transaction)

      unless transaction.update(category: category)
        transaction.destroy # Because duplicate zhash
      end
    end
  end

  def self.classify(transaction)
    # Some example transaction hashes:
    # d456a889ddc87ad41e379de5bb245781333fd883b67bf34eebabd1a6fb7e144a
    # d2ebc0cfd864027eb0887e1dcb772b4d1ca7bc016504889a6843583c2ca73bb4
    # f0d27409c193fef51b66a922794583f08c880ab220229c813995143e1cd244d5
    # c13632d045a685dfead48b62ceb8d0adb188fef9e3f902c65112a88a4dbed4fe

    # transaction = self.find_by(zhash: zhash)

    # to find transactions with nil categories: t = Transaction.where(category: nil)

    if transaction
      if transaction.vin.length > 2
        parsed = transaction.vin.split(',')
        if parsed[0].length > 18 # this is wrong - you need to look for the string "coinbase"
          # vin arr contains coinbase field w/address
          # !!! check this carefully to see that it works
          if transaction.vout.length > 2
            'transparent_coinbase'
          else
            'shielded_coinbase'
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
            if transaction.vShieldedOutput > 0.0
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