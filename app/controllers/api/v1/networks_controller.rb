class Api::V1::NetworksController < ApplicationController

  def index
    @network = Network.network_status
    render json: @network
  end
end