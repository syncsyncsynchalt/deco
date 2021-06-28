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

# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # render new.rhtml
  def new
    session[:site_category] = nil
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token,
              :expires => self.current_user.remember_token_expires_at }
      end
      redirect_to :controller => 'top', :action => 'index'
      flash[:notice] = "ログインしました。"
    else
      render :action => 'new'
    end
  end

  def new_for_administrator
    session[:site_category] = nil
  end

  def login_for_administrator
    if params[:login] == ""
      flash[:notice] = "ユーザ名を入力してください"
      render :action => 'new_for_administrator'
    else
      @user = User.find(:first, :conditions => { :login => params[:login] })
      if @user.category == 1
        self.current_user = User.authenticate(params[:login],
              params[:password])
        if logged_in?
          if params[:remember_me] == "1"
            current_user.remember_me unless current_user.remember_token?
            cookies[:auth_token] = {
                  :value => self.current_user.remember_token ,
                  :expires => self.current_user.remember_token_expires_at }
          end
          redirect_to :controller => 'sys_top', :action => 'index'
          flash[:notice] = "ログインしました。"
        else
          flash[:notice] = "ユーザあるいはパスワードが違います"
          render :action => 'new_for_administrator'
        end
      else
        flash[:notice] = "システム管理者でないかユーザが存在しません"
        render :action => 'new_for_administrator'
      end
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "ログアウトしました。"
    redirect_to :action => 'new'
  end

  def logout_for_administrator
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    render :action => 'new_for_administrator'
  end
end
