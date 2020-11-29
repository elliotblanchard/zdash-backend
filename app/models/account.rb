require 'json'
require 'httparty'
require 'pry'
require_relative './account_transaction'

class Account

  attr_accessor :address, :balance, :firstSeen, :lastSeen, :sentCount, :recvCount, :minedCount, :totalSent, :totalRecv, :sentTrans, :recvTrans

  @@all = []

  def initialize(account_hash)
    account_hash.each {|key, value| self.send(("#{key}="), value)}
    @@all << self
  end

  def self.all
    @@all
  end

  def self.find_by_address(address)
    account_hash = Hash.new

    # make api call for account info
    response = HTTParty.get("https://api.zcha.in/v2/mainnet/accounts/#{address}")
    begin
      parsed = JSON.parse(response.body)
      account_hash = parsed
    rescue JSON::ParserError => e
      return false
    end

    # make api call for last 20 transactions sent
    # https://api.zcha.in/v2/mainnet/accounts/t3Vz22vK5z2LcKEdg16Yv4FFneEL1zg9ojd/sent?limit=20&offset=0&sort=timestamp&direction=descending
    response = HTTParty.get("https://api.zcha.in/v2/mainnet/accounts/#{address}/sent?limit=20&offset=0&sort=timestamp&direction=descending")
    begin
      parsed = JSON.parse(response.body)
      sentTrans = []
      parsed.each do |transaction|
        sentTrans.push(AccountTransaction.new(transaction))
      end
      account_hash[:sentTrans] = sentTrans
    rescue JSON::ParserError => e
      return false
    end

    # make api call for last 20 transations rec'd
    # https://api.zcha.in/v2/mainnet/accounts/t3Vz22vK5z2LcKEdg16Yv4FFneEL1zg9ojd/recv?limit=20&offset=0&sort=timestamp&direction=descending
    response = HTTParty.get("https://api.zcha.in/v2/mainnet/accounts/#{address}/recv?limit=20&offset=0&sort=timestamp&direction=descending")
    begin
      parsed = JSON.parse(response.body)
      recvTrans = []
      parsed.each do |transaction|
        recvTrans.push(AccountTransaction.new(transaction))
      end
      account_hash[:recvTrans] = recvTrans
      return self.new(account_hash)
    rescue JSON::ParserError => e
      return false
    end

  end
end