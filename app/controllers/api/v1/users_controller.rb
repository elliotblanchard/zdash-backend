class Api::V1::UsersController < ApplicationController

  def create
    if (@user = User.find_by(address: user_params[:address]))
      @user.update(name: user_params[:name])
    else
      @user = User.create(user_params)
    end
    render json: @user, status: :created
  end

  def show
    if (@user = User.find_by(address: params[:id]))
      render json: @user, status: :accepted
    else
      @user = {'name': '', 'address': ''}
      render json: @user, status: :accepted
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :address)
  end
end