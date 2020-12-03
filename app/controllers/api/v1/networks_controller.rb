class Api::V1::NetworksController < ApplicationController

  def index
    json = api_req('network')
    network_hash = json
    @network = Network.new(network_hash)
    render json: @network
  end
end