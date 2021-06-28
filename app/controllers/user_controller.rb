# -*- coding: utf-8 -*-
# Copyright (C) 2010 NMT Co.,Ltd.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
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
    @user = User.new(post_params_user)
    @user.save
    if @user.errors.empty?
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

    if @user.update_attributes(post_params_user)
      flash[:notice] = @user.login + 'のパスワードを変更しました。'
    else
      flash[:error] = '失敗'
    end
    redirect_to :controller => :sys_user,
                :action => :index,
                :id => session[:user_category]
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "不正なアクセスです。"
    render :action => "message"
  end

  # MESSAGE
  def message

  end

  private

  def post_params_user
    params.require(:user).permit(
      :category, :login, :name, :password, :password_confirmation, :email, :email, :note
    )
  end
end
