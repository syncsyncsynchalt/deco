# -*- coding: utf-8 -*-
class UserController < ApplicationController
  layout 'system_admin'
  def new
    if session[:user_category]
      @category = session[:user_category]
    else
      render :action => 'blank'
    end
    @user = User.new
  end

  def create
    cookies.delete :auth_token
    @user = User.new(params[:user])
    @user.save
    if @user.errors.empty?
#      redirect_to "/sys_user/index/#{session[:user_category]}"
      redirect_to :controller => :sys_user,
                  :action => :index,
                  :id => session[:user_category]
      flash[:notice] = "登録しました"
    else
      @category = session[:user_category]
      render :action => 'new'
    end
  end

  def pw_update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      flash[:notice] = @user.login + 'のパスワードを変更しました。'
    else
      flash[:error] = '失敗'
    end
#     redirect_back_or_default('/')
#     redirect_to "/sys_user/index/#{session[:user_category]}"
    redirect_to :controller => :sys_user,
                :action => :index,
                :id => session[:user_category]
  end
end
