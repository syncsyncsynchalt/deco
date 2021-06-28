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
class SessionsController < ApplicationController
  def new
    session[:site_category] = nil
  end

  def create
    user =
        User
        .where("login = ?",
               params[:login]).first
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to :controller => 'top', :action => 'index'
      flash[:notice] = "ログインしました。"
    else
      flash[:notice] = "ユーザあるいはパスワードが違います"
      redirect_to :action => 'new'
    end
  end

  def new_for_administrator
    session[:site_category] = nil
  end

  def login_for_administrator
    user =
        User
        .where(["login = ?",
                "category = 1"].join(" AND "),
               params[:login]).first
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to :controller => 'sys_top', :action => 'index'
      flash[:notice] = "ログインしました。"
    else
      flash[:notice] = "ユーザあるいはパスワードが違います"
      redirect_to :action => 'new_for_administrator'
    end
  end

  def destroy
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "ログアウトしました。"
    redirect_to :action => 'new'
  end

  def logout_for_administrator
    cookies.delete :auth_token
    reset_session
    redirect_to :action => 'new_for_administrator'
  end
end
