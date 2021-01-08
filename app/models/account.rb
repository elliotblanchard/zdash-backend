require 'pry'
require_relative './account_transaction'

class Account

  attr_accessor :address, :balance, :firstSeen, :lastSeen, :sentCount, :recvCount, :minedCount, :totalSent, :totalRecv, :sentTrans, :recvTrans

  @@all = []

  def initialize(account_hash)
    account_hash.each { |key, value| send("#{key}=", value) }
  end

end