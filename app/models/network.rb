# require 'json'
# require 'httparty'
require 'pry'

class Network

  attr_accessor :name, :accounts, :transactions, :blockHash, :blockNumber, :difficulty, :hashrate, :meanBlockTime, :peerCount, :protocolVersion, :relayFee, :version, :subVersion, :totalAmount, :sproutPool, :saplingPool  

  @@all = []

  def initialize(network_hash)
    network_hash.each { |key, value| send("#{key}=", value) }
    @@all << self
  end

  def self.all
    @@all
  end
 
end