class Api::V1::UsersController < ApplicationController

  #def index
  #  @users = User.all
  #  render json: @users, status: :accepted
  #end

  def create
    @user = User.create(user_params)
    render json: @user, status: :created
  end

  def show
    if (@user = User.find_by(address: user_params[:id]))
      render json: @user, status: :accepted
    else
      render json: { message: 'No name for this address' }, status: :not_found
    end
  end  

  private

  def user_params
    params.require(:user).permit(:name, :address)
  end
end