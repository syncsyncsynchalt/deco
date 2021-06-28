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
class SysParamController < ApplicationController
  layout 'system_admin'
  before_action :check_ip_for_administrator, :administrator_authorize

  $param_label ||= Hash.new
  $param_label['LOCAL_IPS']             = 'ローカルＩＰアドレス'
  $param_label['LOCAL_DOMAINS']         = 'ローカルドメイン'
  $param_label['FILE_DIR']              = '送信ファイル保存ディレクトリ'
  $param_label['RECEIVERS_LIMIT']       = '受信者数'
  $param_label['FILE_SEND_LIMIT']       = '送信ファイル数'
  $param_label['FILE_SIZE_LIMIT']       = '送信ファイル最大容量'
  $param_label['FILE_TOTAL_SIZE_LIMIT'] = '送信ファイル合計最大容量'
  $param_label['MESSAGE_LIMIT']         = 'メッセージの長さ'
  $param_label['FILE_LIFE_PERIOD']      = '送信ファイル保存期間'
  $param_label['FILE_LIFE_PERIOD_DEF']  = '送信ファイル保存期間デフォルト値'
  $param_label['PW_LENGTH_MIN']         = '最短パスワード長'
  $param_label['PW_LENGTH_MAX']         = '最長パスワード長'
  $param_label['URL']                   = 'ＵＲＬ'
  $param_label['REQUEST_PERIOD']        = '依頼期限'
  $param_label['PASSWORD_AUTOMATION']   = '送信画面のパスワード自動発行'
  $param_label['MODERATE_DEFAULT']      = 'ローカルユーザ決裁ルート'

  $param_label['ENABLE_SSL']            = 'ＳＳＬの利用'

  $param_label['VIRUS_CHECK']           = 'ウィルスチェックの利用'
  $param_label['VIRUS_CHECK_NOTICE']    = 'ウィルス検知の通知'
  $param_label['FROM_MAIL_ADDRESS']     = '送信元メールアドレス'

  $param_label['SEND_MAIL_TITLE']       = '通知メール件名'
  $param_label['SEND_MAIL_CONTENT']     = '通知メール本文見出し'

  $param_unit ||= Hash.new
  $param_unit['RECEIVERS_LIMIT']        = '人'
  $param_unit['FILE_SEND_LIMIT']        = 'ファイル'
  $param_unit['FILE_SIZE_LIMIT']        = 'MB'
  $param_unit['FILE_TOTAL_SIZE_LIMIT']  = 'MB'
  $param_unit['MESSAGE_LIMIT']          = '文字'
  $param_unit['PW_LENGTH_MIN']          = '文字'
  $param_unit['PW_LENGTH_MAX']          = '文字'

  # authorication
  def index
    session[:section_title] = 'パラメータ管理'
    session[:target_for_back_controller] = 'sys_param'
    session[:site_category] = "system"
  end

  # 共通項目
  def common_index
    session[:section_title] = '共通項目の設定'
    session[:target_for_back_controller] = 'sys_param'
    session[:target_for_back] = 'common_index'
    session[:target_for_back_id] = nil
    @app_envs = AppEnv.where(category: 0)
    @moderates = Moderate.all
    @moderate_value = AppEnv.where(category: 0, key: 'MODERATE_DEFAULT').first
    if @moderate_value.present?
      @selected_moderate = Moderate.where(id: @moderate_value.value).first
    end
  end

  # 共通項目２
  def common_index2
    session[:section_title] = '共通項目2の設定'
    session[:target_for_back_controller] = 'sys_param'
    session[:target_for_back] = 'common_index2'
    session[:target_for_back_id] = nil
    @app_envs = AppEnv.where(category: 0)
    @moderates = Moderate.all
    @moderate_value = AppEnv.where(category: 0, key: 'MODERATE_DEFAULT').first
    if @moderate_value.present?
      @selected_moderate = Moderate.where(id: @moderate_value.value).first
    end
  end

  # ローカルユーザ／リモートユーザ
  def user_type_index
    if params[:id] == 'local'
      session[:section_title] = 'ローカルユーザの設定'
      session[:target_for_back_id] = 'local'
      @category = 3
    elsif params[:id] == 'remote'
      session[:section_title] = 'リモートユーザの設定'
      session[:target_for_back_id] = 'remote'
      @category = 2
    end

    if @category.present?
      session[:target_for_back_controller] = 'sys_param'
      session[:target_for_back] = "user_type_index"
      @app_envs = AppEnv.where(category: @category)
      @file_life_periods = AppEnv.
        where(category: @category, key: 'FILE_LIFE_PERIOD').
        order("CAST(app_envs.value AS SIGNED)").
        all
      @file_life_period_value = AppEnv.
        where(category: @category, key: 'FILE_LIFE_PERIOD_DEF').
        first
      if @file_life_period_value.present?
        @selected_file_life_period = AppEnv.
          where(id: @file_life_period_value.value).
          first
      end
    else
      flash[:error] = '失敗'
    end
  end

#  # REMOTE index
#  def remote_index
#    session[:target_for_back] = 'remote_index'
#  
##    @app_envs = AppEnv.find(:all, :conditions => [ "category = ?", 2 ])
#    @app_envs =
#        AppEnv
#        .where([["category = ?",
#                 ].join(" AND "),
#                2,
#                ])
#  end
#
#  # create 登録
#  def create
#    @app_env = AppEnv.new(post_params_app_envs)
#
#    rslt = 0
#    if @app_env.key == 'LOCAL_IPS'
#      unless @app_env.value =~ /^\A(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])((\/(([0-2]?[0-9])|(3[0-2])|(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])))?)\z/
#        flash[:error] = 'ＩＰアドレスではありません'
#        rslt = 1
#      end
#    end
#
#    if @app_env.key == 'PW_LENGTH_MIN'
##      @app_env_check = AppEnv.find(:first,  :conditions => { :key => 'PW_LENGTH_MAX', :category => @app_env.category })
#      @app_env_check =
#          AppEnv
#          .where(:key => 'PW_LENGTH_MAX',
#                 :category => @app_env.category)
#          .first
#      if @app_env_check and @app_env.value.to_i > @app_env_check.value.to_i
#        flash[:error] = '最大パスワード長より小さい数字にしてください'
#        rslt = 1
#      end
#    end
#
#    if @app_env.key == 'PW_LENGTH_MAX'
##      @app_env_check = AppEnv.find(:first,  :conditions => { :key => 'PW_LENGTH_MIN', :category => @app_env.category })
#      @app_env_check =
#          AppEnv
#          .where(:key => 'PW_LENGTH_MIN',
#                 :category => @app_env.category)
#          .first
#      if @app_env_check and @app_env.value.to_i < @app_env_check.value.to_i
#        flash[:error] = '最短パスワード長より大きい数字にしてください'
#        rslt = 1
#      end
#    end
#
#    if @app_env.key == 'FILE_DIR'
#      server_directory = params[:app_env][:value].to_s
#      if !File.exists?(server_directory)
#        flash[:error] = '存在するディレクトリを指定してください'
#        rslt = 1
#      elsif !File.directory?(server_directory)
#        flash[:error] = 'ディレクトリを指定してください'
#        rslt = 1
#      end
#    end
#
#    if rslt == 0
#      if @app_env.save
#        flash[:notice] = "「#{$param_label[@app_env.key]}」を追加しました。"
#      else
#        flash[:error] = '失敗'
#      end
#    end
#    render :action => "message"
#  end

  # 入力項目、選択項目用
  def create
    @app_env = AppEnv.new(post_params_app_envs)

    if @app_env.save
      flash[:notice] = "「#{$param_label[@app_env.key]}」を追加しました。"
    else
      flash[:error] = '失敗'
    end
    render :action => "message"
  end

  # 切り替え（ON/OFF）項目用
  def create2
    @app_env = AppEnv.new(key: params[:id], value: '1', category: '0')

    if @app_env.save
      flash[:notice] = "「#{$param_label[@app_env.key]}」を変更しました。"
    else
      flash[:error] = '失敗'
    end
    render :action => "message"
  end

  # 入力項目、選択項目用
  def edit1
    @app_env = AppEnv.find(params[:id])
    if @app_env.nil?
      flash[:error] = "不正なアクセスです。"
      render :action => "message"
      return
    end
  end

#  # edit1（値の編集　数字のみ）
#  def edit1_only_num
#    @app_env = AppEnv.find(params[:id])
#    if @app_env.nil?
#      flash[:error] = "不正なアクセスです。"
#      render :action => "message"
#    end
#  end

#  # edit2（値、備考の編集）
#  def edit2
#    @app_env = AppEnv.find(params[:id])
#    if @app_env.nil?
#      flash[:error] = "不正なアクセスです。"
#      render :action => "message"
#    else
#      @hour_in_sec = 60 * 60
#      @day_in_sec = @hour_in_sec * 24
#
#      if @app_env.value.to_i >= @day_in_sec
#        @term = @app_env.value.to_i / @day_in_sec
#        @unit = 1
#      else
#        @term = @app_env.value.to_i / @hour_in_sec
#        @unit = 0
#      end
#    end
#  end

#  # update
#  def update
#    @app_env = AppEnv.find(params[:id])
#    app_env = AppEnv.new(post_params_app_envs)
#
#    rslt = 0
#    if @app_env.key == 'LOCAL_IPS'
#      unless app_env.value =~ /^\A(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])((\/(([0-2]?[0-9])|(3[0-2])|(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])))?)\z/
#        flash[:error] = 'ＩＰアドレスを指定してください'
#        rslt = 1
#      end
#    end
#
#    if @app_env.key == 'PW_LENGTH_MIN'
#      @app_env_check =
#          AppEnv
#          .where(:key => 'PW_LENGTH_MAX',
#                 :category => @app_env.category)
#          .first
#      if @app_env_check and app_env.value.to_i > @app_env_check.value.to_i
#        flash[:error] = '最大パスワード長より小さい数字にしてください'
#        rslt = 1
#      end
#    end
#
#    if @app_env.key == 'PW_LENGTH_MAX'
#      @app_env_check =
#          AppEnv
#          .where(:key => 'PW_LENGTH_MIN',
#                 :category => @app_env.category)
#          .first
#      if @app_env_check and app_env.value.to_i < @app_env_check.value.to_i
#        flash[:error] = '最短パスワード長より大きい数字にしてください'
#        rslt = 1
#      end
#    end
#
#    if @app_env.key == 'FILE_DIR'
#      server_directory = params[:app_env][:value].to_s
#      if !File.exists?(server_directory)
#        flash[:error] = '存在するディレクトリを指定してください'
#        rslt = 1
#      elsif !File.directory?(server_directory)
#        flash[:error] = 'ディレクトリを指定してください'
#        rslt = 1
#      end
#    end
#
#    if rslt == 0
#      if @app_env.update_attributes(post_params_app_envs)
#        flash[:notice] = "「#{$param_label[@app_env.key]}」を修正しました。"
#      else
#        flash[:error] = '失敗'
#      end
#    end
#
#    render :action => "message"
#  rescue ActiveRecord::RecordNotFound
#    flash[:error] = "不正なアクセスです。"
#    render :action => "message"
#  end

  # 入力項目、選択項目用
  def update
    @app_env = AppEnv.find(params[:id])
    if @app_env.nil?
      flash[:error] = "不正なアクセスです。"
      render :action => "message"
      return
    end

    @app_env.attributes = post_params_app_envs

    if @app_env.save
      flash[:notice] = "「#{$param_label[@app_env.key]}」を修正しました。"
    else
      flash[:error] = '失敗'
    end
    render :action => "message"
  end

  # 切り替え（ON/OFF）項目用
  def update2
    @app_env = AppEnv.find(params[:id])
    if @app_env.nil?
      flash[:error] = "不正なアクセスです。"
      render :action => "message"
      return
    end

    @app_env.value = (@app_env.value.to_i == 0) ? '1' : '0'

    if @app_env.save
      flash[:notice] = "「#{$param_label[@app_env.key]}」を変更しました。"
    else
      flash[:error] = '失敗'
    end
    render :action => "message"
  end

#  def update_term
#    @app_env = AppEnv.find(params[:id])
#    rslt = 0
#    error_messages = ""
#
#    @term = params[:term]
#    @unit = params[:unit]
#
#    if @unit.to_i == 0
#      unless 1 <= @term.to_i and @term.to_i <= 23
#        error_messages = "1から23の間の数値を指定してください"
#        rslt = 1
#      else
#        @app_env.value = @term.to_i * 60 * 60
#        @term_label = @term + '時間'
#      end
#    elsif @unit.to_i == 1
#      unless 1 <= @term.to_i and @term.to_i <= 14
#        error_messages = "1か14の間の数値を指定してください"
#        rslt = 1
#      else
#        @app_env.value = @term.to_i * 60 * 60 * 24
#        @term_label = @term + '日'
#      end
#    else
#      rslt = 1
#      error_messages = "時間が不正です<br>"
#    end
#
#    if @app_env.key == 'FILE_LIFE_PERIOD' ||
#        @app_env.key == 'REQUEST_PERIOD'
#      @app_env.note = @term_label
#    end
#
#    if rslt == 0
#      @app_env.save
#      flash[:notice] = "「#{$param_label[@app_env.key]}」を修正しました。"
#    else
#      flash[:error] = error_messages
#    end
#
#    render :action => "message"
#
#  rescue ActiveRecord::RecordNotFound
#    flash[:error] = "不正なアクセスです。"
#    render :action => "message"
#  end

  # 削除
  def destroy
    @app_env = AppEnv.where(id: params[:id]).first
    if @app_env.nil?
      flash[:error] = "不正なアクセスです。"
      render :action => "message"
      return
    end

    if @app_env.destroy
      flash[:notice] = "「#{$param_label[@app_env.key]}」[#{@app_env.value}] を削除しました。"
    else
      flash[:error] = '失敗'
    end
    render :action => "message"
  end

  # MESSAGE
  def message
  end

  # 検証
  def validate
    validate_type = params[:validate_type]
    field_id = params[:field_id]
    key = params[:key]
    value = params[:value]
    category = params[:category]

    message = nil
    if validate_type.present? && field_id.present? && key.present? && value.present? && category.present?
      case validate_type
      when 'directory'
        message = AppEnv.
          new(key: key, value: value, category: category).
          validate_directory(true)
      when 'term_unit'
        term = params[:term]
        unit = params[:unit]
        message = AppEnv.
          new(key: key, term: term, unit: unit, category: category).
          validate_term_unit(true)
      when 'pw_length_min_max'
        message = AppEnv.
          new(key: key, value: value, category: category).
          validate_pw_length_min_max(true)
      else
        message = "パラメータエラー"
      end
    else
      message = "パラメータエラー"
    end

    result = Array.new
    result << field_id
    result << message.blank?
    result << message

    respond_to do |format|
      format.json { render json: result }
    end
  end

  private

  def post_params_app_envs
    params.require(:app_env).permit(
      :key, :value, :term, :unit, :category
    )
  end
end
