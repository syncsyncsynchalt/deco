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
class SysUserController < ApplicationController
  layout 'system_admin'
#  include AuthenticatedSystem
  before_filter :check_ip_for_administrator, :administrator_authorize

  def index
    session[:section_title] = 'ユーザ管理'

    @category = params[:id]
    session[:user_category] = @category
    if @category == '1'
      session[:section_title] = 'システム管理者'
      session[:target_for_back] = 'index'
      session[:return_to] = '/sys_user/index/1'
      session[:target_for_back_id] = 1
      @users =
          User.where("category = ?", 1)
#      @users = User.find(:all, :conditions => [ "category = ?", 1 ])

    elsif @category == '2'
      session[:section_title] = 'リモートユーザ'
      session[:target_for_back] = 'index'
      session[:return_to] = '/sys_user/index/2'
      session[:target_for_back_id] = 2
      @users =
          User.where("category = ?", 2)
#      @users = User.find(:all, :conditions => [ "category = ?", 2 ])

    end
  end

  # edit（編集）
  def edit
    @user = User.find(params[:id])
  end

  #パスワード変更
  def chg_pw
    @user = User.find(params[:id])
  end

  #決裁ルート変更
  def chg_moderate
    @user = User.find(params[:id])
    @moderates = Moderate.find(:all)
  end

  # update
  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      flash[:notice] = @user.login + 'を更新しました。'
    else
      flash[:error] = '失敗'
    end
    render :action => "message"
  end

  # destroy
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    flash[:notice] = @user.login + '[' + @user.email + '] を削除しました。'
    render :action => "message"
  end

  def message
  end
end
