class Api::V1::TransactionsController < ApplicationController

  def index
    @transactions = Transactions.find_by_date(params[:date_range])
    render json: @transactions
  end
end
