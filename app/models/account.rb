require 'json'
require 'httparty'
require 'pry'
require_relative './account_transaction'

class Account

  attr_accessor :address, :balance, :firstSeen, :lastSeen, :sentCount, :recvCount, :minedCount, :totalSent, :totalRecv, :sentTrans, :recvTrans

  @@all = []

  def initialize(account_hash)
    account_hash.each { |key, value| send("#{key}=", value) }
    @@all << self
  end

  def self.all
    @@all
  end

  def self.find_by_address(address)

    # make api call for account info
    response = HTTParty.get("https://api.zcha.in/v2/mainnet/accounts/#{address}")
    begin
      parsed = JSON.parse(response.body)
      account_hash = parsed
    rescue JSON::ParserError => e
      return false
    end

    # make api call for last 20 transactions sent
    response = HTTParty.get("https://api.zcha.in/v2/mainnet/accounts/#{address}/sent?limit=20&offset=0&sort=timestamp&direction=descending")
    begin
      parsed = JSON.parse(response.body)
      sent_trans = []
      parsed.each do |transaction|
        sent_trans.push(AccountTransaction.new(transaction))
      end
      account_hash[:sentTrans] = sent_trans
    rescue JSON::ParserError => e
      return false
    end

    # make api call for last 20 transations rec'd
    response = HTTParty.get("https://api.zcha.in/v2/mainnet/accounts/#{address}/recv?limit=20&offset=0&sort=timestamp&direction=descending")
    begin
      parsed = JSON.parse(response.body)
      recv_trans = []
      parsed.each do |transaction|
        recv_trans.push(AccountTransaction.new(transaction))
      end
      account_hash[:recvTrans] = recv_trans
      new(account_hash)
    rescue JSON::ParserError => e
      false
    end

  end
end