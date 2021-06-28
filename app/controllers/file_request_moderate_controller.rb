# -*- encoding: utf-8 -*-
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
class FileRequestModerateController < ApplicationController
  before_filter :load_env
  before_filter :url_check_for_request_moderater, :except => [:message]
  before_filter :check_auth, :except => [:login, :auth, :message]

  def index
    @request_moderater = RequestModerater.find(:first, :conditions => {:url => params[:id]})
    @request_moderate = @request_moderater.request_moderate
    @moderate_user = @request_moderater.user
    @request_matter = @request_moderate.request_matter
    @requested_matters = @request_matter.requested_matters
    @moderate = @request_moderater.moderater.moderate
    @request_moderaters = @request_moderate.request_moderaters
  end

  def login
    @request_moderater = RequestModerater.find(:first, :conditions => {:url => params[:id]})

    @moderate_user = @request_moderater.user
    login_user = User.find(:first,
          :conditions => {:id => session[:user_id].to_i})
    if @moderate_user == nil
      flash[:notice] = "不正なアクセスかURLが間違っております。"
      redirect_to :action => :message
      return
    end

    session[:request_moderater_id] = @request_moderater.id
    if current_user
      if @moderate_user.id == login_user.id
        if @request_moderater.result == 0
          flash[:notice] = "以下の依頼内容の決裁を行って下さい。"
        end
        redirect_to :action => :index, :id => params[:id]
        return
      else
        flash[:notice] = "不正なアクセスです。(ログインしているユーザが一致しません。)"
        redirect_to :action => :message
        return
      end
    else
      if @request_moderater.result > 0
        flash[:notice] = "決裁完了しております。確認を行う場合はログインを行って下さい。"
        return
      else
        if flash[:notice] == nil
          flash[:notice] = "決裁を行います。決裁ユーザのログインを行って下さい。"
        end
      end
    end
  end

  def auth
    @request_moderater = RequestModerater.find(:first, :conditions => {:id => session[:request_moderater_id]})
    @moderate_user = @request_moderater.user
    if @moderate_user && @moderate_user.authenticate(params[:password])
      session[:user_id] = @moderate_user.id
      flash[:notice] = "ログインしました、以下の送信内容の決裁を行って下さい。"
      session[:login] = "1"
      session[:user_id] = @moderate_user.id
      redirect_to :action => :index, :id => params[:id]
      return
    else
      flash[:notice] = "パスワードが一致しません。"
      redirect_to :action => :login, :id => @request_moderater.url
      return
    end
  end

  def new
    @request_moderater = RequestModerater.find(:first,
            :conditions => {:url => params[:id]})
  end

  def approval
    @request_moderater = RequestModerater.find(:first, :conditions => {:url => params[:id]})
    @request_moderate = @request_moderater.request_moderate
    @request_matter = @request_moderate.request_matter
    @requested_matters = @request_matter.requested_matters
    port = get_port()
    ActiveRecord::Base.transaction do
      # 通常決裁
      if @request_moderate.type_flag == 0
        @request_moderaters = @request_moderate.request_moderaters
        moderater_count = @request_moderater.number + 1
        if moderater_count > @request_moderaters.length
          # 決裁終了
          @request_moderater.result = 1
          @request_moderater.save!
          @request_moderate.result = 1
          @request_moderate.moderated_at = Time.now
          @request_moderate.save!
          # 決裁結果を更新
          @request_matter.moderate_result = 1
          @request_matter.sent_at = Time.now
          @request_matter.save!
          flash[:notice] = "決裁が完了しました"
            @requested_matters.each do |requested_matter|
              full_url = port + "://" + $app_env['URL'] +
                  "/requested_file_send/login/" + requested_matter.url

              Notification.request_report(@request_matter,
                                          requested_matter.name, requested_matter.mail_address,
                                          full_url, requested_matter.send_password,
                                          $app_env['REQUEST_PERIOD'].to_i).deliver
              Notification.request_password_report(@request_matter,
                                          @requested_matter.name, requested_matter.mail_address,
                                          full_url, requested_matter.send_password,
                                          $app_env['REQUEST_PERIOD'].to_i).deliver
            end
          url_dl = port + "://" + $app_env['URL']
          Notification.send_result_report(@request_matter,
                                          @requested_matters,
                                          url_dl).deliver
        else
          @request_moderater.result = 1
          @request_moderater.save!
          # 次の決裁者へ
          @next_moderater =
              RequestModerater
              .where(["request_moderate_id = ?",
                      "number = ?"].join(" AND "),
                      @request_moderate.id, moderater_count).first
          if @next_moderater.present?
            url = port + "://" + $app_env['URL']
            Notification
                .request_matter_moderate_report(@request_matter, @next_moderater,
                    @next_moderater.user, url).deliver
            @next_moderater.send_flag = 1
            @next_moderater.save
            flash[:notice] = "決裁が完了しました"
          else
            @requested_matters.each do |requested_matter|
              full_url = port + "://" + $app_env['URL'] +
                  "/requested_file_send/login/" + requested_matter.url

              Notification.request_report(@request_matter,
                                          requested_matter.name, requested_matter.mail_address,
                                          full_url, requested_matter.send_password,
                                          $app_env['REQUEST_PERIOD'].to_i).deliver
              Notification.request_password_report(@request_matter,
                                          @requested_matter.name, requested_matter.mail_address,
                                          full_url, requested_matter.send_password,
                                          $app_env['REQUEST_PERIOD'].to_i).deliver
            end
            url_dl = port + "://" + $app_env['URL']
            Notification.send_result_report(@request_matter,
                                            @requested_matters,
                                            url_dl).deliver
            flash[:notice] = "決裁が完了しました"
          end
        end
      # 簡易決裁
      else
          # 決裁終了
          @request_moderater.result = 1
          @request_moderater.save!
          @request_moderate.result = 1
          @request_moderate.moderated_at = Time.now
          @request_moderate.save!
          # 決裁結果を更新
          @request_matter.moderate_result = 1
          @request_matter.sent_at = Time.now
          @request_matter.save!
          flash[:notice] = "決裁が完了しました"
          @requested_matters.each do |requested_matter|
            full_url = port + "://" + $app_env['URL'] +
                "/requested_file_send/login/" + requested_matter.url
            Notification.request_report(@request_matter,
                                        requested_matter.name, requested_matter.mail_address,
                                        full_url, requested_matter.send_password,
                                        $app_env['REQUEST_PERIOD'].to_i).deliver
            Notification.request_password_report(@request_matter,
                                        requested_matter.name, requested_matter.mail_address,
                                        full_url, requested_matter.send_password,
                                        $app_env['REQUEST_PERIOD'].to_i).deliver
          end
          req_url = port + "://" + $app_env['URL'] + "/requested_file_send/login/"
          @requested_matters = @request_matter.requested_matters
          Notification.request_copied_report(@request_matter,
                                         @requested_matters, req_url,
                                         $app_env['REQUEST_PERIOD'].to_i).deliver
          flash[:notice] = "決裁が完了しました"
      end
    end
    redirect_to :action => :message
  end

  def create
    @request_moderater = RequestModerater.find(:first,
            :conditions => {:url => params[:id]})
    @request_moderate = @request_moderater.request_moderate
    @request_matter = @request_moderate.request_matter
    @request_moderaters = @request_moderate.request_moderaters
    port = get_port()
    ActiveRecord::Base.transaction do
      @request_moderater.result = 2
      @request_moderater.content = params[:request_modertaer][:content]
      @request_moderater.save!

      @request_moderate.result = 2
      @request_moderate.moderated_at = Time.now
      @request_moderate.save!
      # 決裁結果を更新
      @request_matter.moderate_result = 2
      @request_matter.save!
    end
    port = get_port()
    url = port + "://" + $app_env['URL']
    Notification.request_matter_moderate_result_report(@request_matter,
                                    @request_moderater,
                                    url).deliver
    flash[:notice] = "決裁が完了しました"
    redirect_to :action => :message
  end

  private

  def check_auth
    if current_user.present?
      @request_moderater = RequestModerater.find(:first, :conditions => {:url => params[:id], :send_flag => 1})
      @moderate_user = @request_moderater.user
      unless @moderate_user.id == current_user.id
        flash[:notice] = "不正なアクセスです。(ログインしているユーザが一致しません。)"
        redirect_to :action => :message
        return
      end
    else
      redirect_to :action => :login, :id => params[:id]
      return
    end
  end

  def url_check_for_request_moderater
    @request_moderater = RequestModerater.find(:first, :conditions => {:url => params[:id]})
    unless @request_moderater.present? && @request_moderater.send_flag == 1
      flash[:notice] = "不正なアクセスかURLが間違っております。"
      redirect_to :action => :message
      return
    end
  end

  def authorize_for_request_moderater
    @request_moderater = RequestModerater.find(:first, :conditions => {:url => params[:id], :send_flag => 1})
    @moderate_user = @request_moderater.moderater.user
    login_user = User.find(:first,
          :conditions => {:id => session[:user_id].to_i})
    if @moderate_user == nil || @request_moderater.send_flag == 0
      flash[:notice] = "不正なアクセスかURLが間違っております。"
      redirect_to :action => :message
      return
    end

    unless login_user == nil
      unless @moderate_user.id == login_user.id
        flash[:notice] = "不正なアクセスです。(ログインしているユーザが一致しません。)"
        redirect_to :action => :message
        return
      end
    end
  end
end
