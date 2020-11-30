require 'json'
require 'httparty'
require 'pry'

class Network

  attr_accessor :name, :accounts, :transactions, :blockHash, :blockNumber, :difficulty, :hashrate, :meanBlockTime, :peerCount, :protocolVersion, :relayFee, :version, :subVersion, :totalAmount, :sproutPool, :saplingPool  

  @@all = []

  def initialize(account_hash)
    account_hash.each { |key, value| send("#{key}=", value) }
    @@all << self
  end

  def self.all
    @@all
  end

  def self.network_status    
    # https://api.zcha.in/v2/mainnet/network

    # make api call for account info
    response = HTTParty.get("https://api.zcha.in/v2/mainnet/network")
    begin
      parsed = JSON.parse(response.body)
      network_hash = parsed
      new(network_hash)
    rescue JSON::ParserError => e
      false
    end

  end
 
end