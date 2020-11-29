require 'json'
require 'open-uri'
require 'httparty'

class Account

  attr_accessor :address, :balance, :firstSeen, :lastSeen, :sentCount, :recvCount, :minedCount, :totalSent, :totalRecv

  @@all = []

  def initialize(account_hash)
    account_hash.each {|key, value| self.send(("#{key}="), value)}
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
      # return parsed["data"]["text"]
      return self.new(parsed)
    rescue JSON::ParserError => e
      return false
    end

    # make api call for last 1,000 transactions sent

    # make api call for last 1,000 transations rec'd

    # return account object with account info + last 1,000 transactions rec'd and sent
    # OR error if account does not exist
  end
end