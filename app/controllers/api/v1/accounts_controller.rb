class Api::V1::AccountsController < ApplicationController

  def index
    json = api_req("accounts?sort=lastSeen&direction=descending&limit=20&offset=0")
    @accounts_recent = []
    json.each { |account| @accounts_recent.push(Account.new(account)) }
    render json: @accounts_recent
  end

  def show
    json = api_req("accounts/#{params[:id]}")
    account_hash = json

    json = api_req("accounts/#{params[:id]}/sent?limit=20&offset=0&sort=timestamp&direction=descending")
    sent_trans = []
    json.each { |transaction| sent_trans.push(AccountTransaction.new(transaction)) }
    account_hash[:sentTrans] = sent_trans

    json = api_req("accounts/#{params[:id]}/recv?limit=20&offset=0&sort=timestamp&direction=descending")
    recv_trans = []
    json.each { |transaction| recv_trans.push(AccountTransaction.new(transaction)) }
    account_hash[:recvTrans] = recv_trans
    @account = Account.new(account_hash)

    render json: @account
  end

end
