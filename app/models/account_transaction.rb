class AccountTransaction

  attr_accessor :hash, :mainChain, :fee, :type, :shielded, :index, :blockHash, :blockHeight, :version, :lockTime, :timestamp, :time, :vin, :vout, :vjoinsplit, :vShieldedOutput, :vShieldedSpend, :valueBalance, :value, :outputValue, :shieldedValue, :overwintered

  @@all = []
  
  def initialize(account_hash)
    account_hash.each { |key, value| send("#{key}=", value) }
    @@all << self
  end
  
  def self.all
    @@all
  end
end