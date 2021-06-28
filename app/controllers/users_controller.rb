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

class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  layout 'system_admin'
  include AuthenticatedSystem
  before_filter :check_ip_for_administrator, :administrator_authorize
  def new
    if session[:user_category]
      @category = session[:user_category]
    else
      render :action => 'blank'
    end
  end

  def create
    cookies.delete :auth_token
    @user = User.new(params[:user])
    @user.save
    if @user.errors.empty?
      redirect_back_or_default('/')
      flash[:notice] = "登録しました"
    else
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
    redirect_back_or_default('/')
  end

  def blank
  end
end

module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter
      def select_all(sql, name = nil)
        sql = sql[:sql] if sql.is_a?(Hash)
        select(sql, name)
      end
    end
  end
end