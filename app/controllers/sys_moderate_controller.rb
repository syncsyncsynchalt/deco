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
class SysModerateController < ApplicationController
  layout 'system_admin'
  before_filter :check_ip_for_administrator, :administrator_authorize

  def index
    session[:target_for_back_controller] = 'sys_moderate'
    session[:section_title] = '決裁管理'
    session[:target_for_back] = 'index'
    session[:target_for_back_id] = nil
    @moderates = Moderate.find(:all)
  end

  def new
    @users = User.find(:all)
    @user_count = User.find(:all).count
  end

  def create
    @moderate = Moderate.new(params[:moderate])
    moderater_flag = 0
    if params[:moderate].present?
      for user_id in params[:moderater][:user_id]
        if user_id.present?
          moderater_flag += 1
        end
      end
    end
    if moderater_flag >= 1 && moderater_flag <= 10
      ActiveRecord::Base.transaction do
        @moderate.use_flag = 1
        @moderate.save!
        moderater_count = 0
        for user_id in params[:moderater][:user_id]
          if user_id.present?
            moderater_count += 1
            @moderater = Moderater.new()
            @moderater.user_id = user_id.to_i
            @moderater.moderate = @moderate
            @moderater.number = moderater_count
            @moderater.save!
          end
        end
      end
      flash[:notice] = '決裁ルートを登録しました。'
      render :action => "message"
    elsif moderater_flag > 10
      @users = User.find(:all)
      @user_count = User.find(:all).count
      flash[:error] = '決裁者は最大10名までです'
      render :action => "new"
    else
      @users = User.find(:all)
      @user_count = User.find(:all).count
      flash[:error] = '決裁者を選択してください'
      render :action => "new"
    end
  end

  def edit
    @users = User.find(:all)
    @user_count = User.find(:all).count
    @moderate = Moderate.find(params[:id])
    @moderaters = @moderate.moderaters
    @moderaters_lists = Array.new
    for moderater in @moderaters
      if moderater.present?
        @moderaters_lists.push moderater.user_id
      end
    end
  end

  def update
    @moderate = Moderate.find(params[:id])
    if @moderate.present?
      moderater_flag = 0
      if params[:moderater].present?
        for user_id in params[:moderater][:user_id]
          if user_id.present?
            moderater_flag += 1
          end
        end
      end
      if moderater_flag >= 1 && moderater_flag <= 10
        if @moderate.update_attributes(params[:moderate])
          moderater_count = 0
          @moderaters = @moderate.moderaters
          moderater_size = @moderaters.length
          for user_id in params[:moderater][:user_id]
            if user_id.present?
              moderater_count += 1
              @moderater =
                  Moderater
                  .where(["moderate_id = ?",
                          "number = ?"].join(" AND "),
                  @moderate.id, moderater_count).first
              unless @moderater.present?
                @moderater = Moderater.new()
                @moderater.moderate = @moderate
                @moderater.number = moderater_count
              end
              @moderater.user_id = user_id.to_i
              @moderater.save!
            end
          end
          if moderater_size > moderater_count
            @moderaters =
                Moderater
                .where(["moderate_id = ?",
                        "number > ?"].join(" AND "),
                @moderate.id, moderater_count)
            @moderaters.destroy_all
          end
          flash[:notice] = '決裁ルートを更新しました。'
          render :action => "message"
        else
          flash[:error] = '失敗'
          render :action => "message"
        end
      elsif moderater_flag > 10
        @users = User.find(:all)
        @user_count = User.find(:all).count
        @moderaters = @moderate.moderaters
        @moderaters_lists = Array.new
        for user_id in params[:moderater][:user_id]
          if user_id.present?
            @moderaters_lists.push user_id
          end
        end
        flash[:error] = '決裁者は最大10名までです'
        render :action => "edit"
      else
        @users = User.find(:all)
        @user_count = User.find(:all).count
        @moderaters = @moderate.moderaters
        @moderaters_lists = Array.new
        for user_id in params[:moderater][:user_id]
          if user_id.present?
            @moderaters_lists.push user_id
          end
        end
        flash[:error] = '決裁者を選択してください'
        render :action => "edit"
      end
    else
      flash[:error] = '決裁情報が見つかりません(既に削除されたか不正なアクセスです)'
      render :action => "message"
    end
  end

  def destroy
    @moderate = Moderate.find(params[:id])

    @users =
        User
        .where("moderate_id = ?",
               @moderate.id)
    @local_moderate =
        AppEnv
        .where(["category = ?",
                "`key` = ?"].join(" AND "),
               0, 'MODERATE_DEFAULT').first
    if @users.present?
      flash[:error] = '決裁ルートが選択されているユーザが存在します。ユーザの決裁ルートを変更してから削除してください。'
      redirect_to :action => :index
    elsif @local_moderate.present? &&
        @local_moderate.value.to_i == params[:id].to_i
      flash[:error] = 'ローカルユーザの決裁ルートに選択されています。ローカルユーザの決裁ルートを変更してから削除してください。'
      redirect_to :action => :index
    else
      @moderaters = @moderate.moderaters
      @moderaters.destroy_all
      @moderate.destroy
      flash[:notice] = '決裁ルートを削除しました。'
      render :action => "message"
    end
  end
end
