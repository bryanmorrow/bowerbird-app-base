# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_admin!
  before_action :set_user, only: %i[edit update destroy]

  def index
    @users = User.order(:name, :email)
  end

  def new
    @user = User.new(role: "member")
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path, notice: "User created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    attrs = user_params
    attrs = attrs.except(:password, :password_confirmation) if attrs[:password].blank?
    if @user.update(attrs)
      redirect_to users_path, notice: "User updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to users_path, alert: "You can't delete your own account."
      return
    end
    @user.destroy
    redirect_to users_path, notice: "User removed."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :admin)
  end

  def require_admin!
    return if current_user&.admin?

    redirect_to root_path, alert: "Admin access required."
  end
end
