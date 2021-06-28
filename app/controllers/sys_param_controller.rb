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

class SysParamController < ApplicationController
  layout 'system_admin'
  before_filter :check_ip_for_administrator, :administrator_authorize

  $param_label = Hash.new
  $param_label['LOCAL_IPS']        = 'ローカルＩＰ'
  $param_label['LOCAL_DOMAINS']    = 'ローカルドメイン'
  $param_label['FILE_DIR']         = '送信ファイル保存ディレクトリ'
  $param_label['RECEIVERS_LIMIT']  = '受信者数'
  $param_label['FILE_SEND_LIMIT']  = '送信ファイル数'
  $param_label['FILE_SIZE_LIMIT']  = '送信ファイル最大容量'
  $param_label['FILE_TOTAL_SIZE_LIMIT'] = '送信ファイル合計最大容量'
  $param_label['MESSAGE_LIMIT']    = 'メッセージの長さ'
  $param_label['FILE_LIFE_PERIOD'] = '送信ファイル保存期間（秒）'
  $param_label['FILE_LIFE_PERIOD_DEF'] = '送信ファイル保存期間デフォルト値'
  $param_label['PW_LENGTH_MIN']    = '最短パスワード長'
  $param_label['PW_LENGTH_MAX']    = '最長パスワード長'
  $param_label['URL']              = 'ＵＲＬ'
  $param_label['REQUEST_PERIOD']   = '依頼期限（秒）'

  # authorication
  def index
    session[:section_title] = 'パラメータ管理'
    session[:site_category] = "system"

  end

  #COMMON index
  def common_index
    session[:section_title] = '共通項目の設定'
    session[:target_for_back] = 'common_index'
    session[:target_for_back_id] = nil
    @app_envs = AppEnv.find(:all, :conditions => [ "category = ?", 0 ])
  end

  # create 登録
  def create
    @app_env = AppEnv.new(params[:app_env])

    rslt = 0
    if @app_env.key == 'LOCAL_IPS'
      unless @app_env.value =~ /^\d+\.\d+\.\d+\.\d+|\d+\.\d+\.\d+\.\d+\/\d+$/
        flash[:error] = 'ＩＰアドレスではありません'
        rslt = 1
      end
    end

    if @app_env.key == 'PW_LENGTH_MIN'
      @app_env_check = AppEnv.find(:first, 
              :conditions => {
                :key => 'PW_LENGTH_MAX',
                :category => @app_env.category })
      if @app_env_check and @app_env.value.to_i > @app_env_check.value.to_i
        flash[:error] = '最大パスワード長より小さい数字にしてください'
        rslt = 1
      end
    end

    if @app_env.key == 'PW_LENGTH_MAX'
      @app_env_check = AppEnv.find(:first, 
              :conditions => {
                :key => 'PW_LENGTH_MIN',
                :category => @app_env.category })
      if @app_env_check and @app_env.value.to_i < @app_env_check.value.to_i
        flash[:error] = '最短パスワード長より大きい数字にしてください'
        rslt = 1
      end
    end

    if rslt == 0
      if @app_env.save
        flash[:notice] = @app_env.key + 'を追加しました。'
      else
        flash[:error] = '失敗'
      end
    end
    render :action => "message"
  end

  # edit1（値の編集）
  def edit1
    @app_env = AppEnv.find(params[:id])
  end

  # edit1（値の編集　数字のみ）
  def edit1_only_num
    @app_env = AppEnv.find(params[:id])
  end

  # edit2（値、備考の編集）
  def edit2
    @app_env = AppEnv.find(params[:id])
  end

  # update
  def update
    @app_env = AppEnv.find(params[:id])
    app_env = AppEnv.new(params[:app_env])

    rslt = 0
    if @app_env.key == 'LOCAL_IPS'
      unless app_env.value =~ /^\d+\.\d+\.\d+\.\d+|\d+\.\d+\.\d+\.\d+\/\d+$/
        flash[:error] = 'ＩＰアドレスではありません'
        rslt = 1
      end
    end

    if @app_env.key == 'PW_LENGTH_MIN'
      @app_env_check = AppEnv.find(:first, 
              :conditions => {
                :key => 'PW_LENGTH_MAX',
                :category => @app_env.category })
      if @app_env_check and app_env.value.to_i > @app_env_check.value.to_i
        flash[:error] = '最大パスワード長より小さい数字にしてください'
        rslt = 1
      end
    end

    if @app_env.key == 'PW_LENGTH_MAX'
      @app_env_check = AppEnv.find(:first, 
              :conditions => {
                :key => 'PW_LENGTH_MIN',
                :category => @app_env.category })
      if @app_env_check and app_env.value.to_i < @app_env_check.value.to_i
        flash[:error] = '最短パスワード長より大きい数字にしてください'
        rslt = 1
      end
    end

    if rslt == 0
      if @app_env.update_attributes(params[:app_env])
        flash[:notice] = @app_env.key + 'を修正しました。'
      else
        flash[:error] = '失敗'
      end
    end

    render :action => "message"
  end

  # destroy
  def destroy
    @app_env = AppEnv.find(:first, :conditions => {:id => params[:id]})
    if @app_env
      flash[:notice] = @app_env.key + '[' + @app_env.value + '] を削除しました。'
      @app_env.destroy
    else
      flash[:notice] = 'パラメータが存在しません。'
    end

    render :action => "message"
  end

  # LOCAL index
  def user_type_index
    if params[:id] == 'local' or params[:id] == 'remote'
    
      if params[:id] == 'local'
        session[:section_title] = 'ローカルユーザの設定'
        session[:target_for_back] = 'user_type_index'
        session[:target_for_back_id] = 'local'
        @category = 3
        @app_envs = AppEnv.find(:all,
                :conditions => [ "category = ?", @category ])

      elsif params[:id] = 'remote'
        session[:section_title] = 'リモートユーザの設定'
        session[:target_for_back] = "user_type_index"
        session[:target_for_back_id] = 'remote'
        @category = 2
        @app_envs = AppEnv.find(:all,
                :conditions => [ "category = ?", @category ])

      end

      @file_life_periods = Array.new
      @file_life_periods_for_sort = Array.new
      @file_life_periods_label = Hash.new
      @app_envs.each do |app_env|
        if app_env.key == 'FILE_LIFE_PERIOD'
          @file_life_periods_for_sort.push [app_env.id, app_env.value.to_i]
          @file_life_periods_label[app_env.id] = app_env.note
        end
      end
      @file_life_periods_for_sort =
              @file_life_periods_for_sort.sort{|a ,b| a[1] <=> b[1]}

      @file_life_periods_for_sort.each do |buff|
        @file_life_periods.push [@file_life_periods_label[buff[0]], buff[0]]
      end

    else
      flash[:error] = '失敗'
    end
  end

  # REMOTE index
  def remote_index
    session[:target_for_back] = 'remote_index'
  
    @app_envs = AppEnv.find(:all, :conditions => [ "category = ?", 2 ])
  end

  # MESSAGE
  def message

  end
end
