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
class SysTopController < ApplicationController
  layout 'system_admin'
  before_filter :administrator_authorize
  def index
    session[:section_title] = 'システム管理画面'
    session[:target_for_back] = 'index'
    session[:target_for_back_id] = nil
  end

  def init_permit_ip
    session[:section_title] = 'システム管理画面アクセスＩＰアドレスの設定'
    session[:target_for_back] = 'init_permit_ip'
    session[:target_for_back_id] = nil
    @app_envs = AppEnv.find(:all,
            :conditions => { :key => "PERMIT_OPERATION_IPS" })
  end

  # create 登録
  def param_create
    @app_env = AppEnv.new(params[:app_env])

    result = 0
    if @app_env.key == 'PERMIT_OPERATION_IPS'
      unless @app_env.value =~ /^\d+\.\d+\.\d+\.\d+|\d+\.\d+\.\d+\.\d+\/\d+$/
        flash[:error] = 'ＩＰアドレスではありません'
        result = 1
      end
    end

    if result == 0
      if @app_env.save
        flash[:notice] = @app_env.key + 'を追加しました。'
      else
        flash[:error] = '失敗'
      end
    end

    render :action => "message"
  end

  def param_create_
    @app_env = AppEnv.new(params[:app_env])

    if @app_env.save
      flash[:notice] = @app_env.key + 'を追加しました。'
    else
      flash[:error] = '失敗'
    end

    render :action => "message"
  end

  # edit1（値の編集）
  def param_edit1
    @app_env = AppEnv.find(params[:id])
  end

  # update
  def param_update
    @app_env = AppEnv.find(params[:id])
    app_env = AppEnv.new(params[:app_env])

    result = 0
    if @app_env.key == 'PERMIT_OPERATION_IPS'
      unless app_env.value =~ /^\d+\.\d+\.\d+\.\d+|\d+\.\d+\.\d+\.\d+\/\d+$/
        flash[:error] = 'ＩＰアドレスではありません'
        result = 1
      end
    end

    if result == 0
      if @app_env.update_attributes(params[:app_env])
        flash[:notice] = @app_env.key + 'を修正しました。'
      else
        flash[:error] = '失敗'
      end
    end

    render :action => "message"
  end

  def param_update_
    @app_env = AppEnv.find(params[:id])

    if @app_env.update_attributes(params[:app_env])
      flash[:notice] = @app_env.key + 'を修正しました。'
    else
      flash[:error] = '失敗'
    end
    render :action => "message"
  end

  # destroy
  def param_destroy
    @app_env = AppEnv.find(params[:id])
    @app_env.destroy

    flash[:notice] = @app_env.key + '[' + @app_env.value + '] を削除しました。'
    render :action => "message"
  end

  def message
  end
end
