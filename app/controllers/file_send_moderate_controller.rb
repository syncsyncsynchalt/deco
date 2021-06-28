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
class FileSendModerateController < ApplicationController
  before_filter :load_env
  before_filter :url_check_for_send_moderater, :except => [:message]
  before_filter :check_auth, :except => [:login, :auth, :message]

  def index
    @send_moderater = SendModerater.find(:first, :conditions => {:url => params[:id]})
    @send_moderate = @send_moderater.send_moderate
    @moderate_user = @send_moderater.user
    @send_matter = @send_moderate.send_matter
    @receivers = @send_matter.receivers
    @attachments = @send_matter.attachments
    @moderate = @send_moderater.moderater.moderate
    @send_moderaters = @send_moderate.send_moderaters
  end

  def login
    @send_moderater = SendModerater.find(:first, :conditions => {:url => params[:id]})

    @moderate_user = @send_moderater.user
    login_user = User.find(:first,
          :conditions => {:id => session[:user_id].to_i})
    if @moderate_user == nil
      flash[:notice] = "不正なアクセスかURLが間違っております。"
      redirect_to :action => :message
      return
    end

    session[:send_moderater_id] = @send_moderater.id
    if current_user
      if @moderate_user.id == login_user.id
        if @send_moderater.result == 0
          flash[:notice] = "以下の送信内容の決裁を行って下さい。"
        end
        redirect_to :action => :index, :id => params[:id]
        return
      else
        flash[:notice] = "不正なアクセスです。(ログインしているユーザが一致しません。)"
        redirect_to :action => :message
        return
      end
    else
      if @send_moderater.result > 0
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
    @send_moderater = SendModerater.find(:first, :conditions => {:id => session[:send_moderater_id]})
    @moderate_user = @send_moderater.user
    if @moderate_user && @moderate_user.authenticate(params[:password])
      session[:user_id] = @moderate_user.id
      flash[:notice] = "ログインしました、以下の送信内容の決裁を行って下さい。"
      session[:login] = "1"
      session[:user_id] = @moderate_user.id
      redirect_to :action => :index, :id => params[:id]
      return
    else
      flash[:notice] = "パスワードが一致しません。"
      redirect_to :action => :login, :id => @send_moderater.url
      return
    end
  end

  def get
    @attachment = Attachment.find(:first, :conditions => {:id => params[:attachment].to_i})
    if @attachment == nil
      flash[:notice] = "ファイルが存在しません。"
      redirect_to :action => :message
      return
    end
    if @attachment.virus_check == '0'
      if request.user_agent =~ /Windows/i
        @filename = @attachment.name.encode("Windows-31J")
      elsif request.user_agent =~ /Mac/i
        @filename = @attachment.name
      else
        @filename = @attachment.name
      end
      send_file $app_env['FILE_DIR'] + "/#{@attachment.id}",
                :filename => @filename,
                :type => @attachment.content_type,
                :x_sendfile => true
=begin
      send_file $app_env['FILE_DIR'] + "/#{@attachment.id}",
                :filename => @filename,
                :type => @attachment.content_type
=end
    end
  end

  def new
    @send_moderater = SendModerater.find(:first,
            :conditions => {:url => params[:id]})
  end

  def approval
    @send_moderater = SendModerater.find(:first, :conditions => {:url => params[:id]})
    @send_moderate = @send_moderater.send_moderate
    @send_matter = @send_moderate.send_matter
    @receivers = @send_matter.receivers
    @attachments = @send_matter.attachments
    port = get_port()
    ActiveRecord::Base.transaction do
      # 通常決裁
      if @send_moderate.type_flag == 0
        @send_moderaters = @send_moderate.send_moderaters
        moderater_count = @send_moderater.number + 1
        if moderater_count > @send_moderaters.length
          # 決裁終了
          @send_moderater.result = 1
          @send_moderater.save!
          @send_moderate.result = 1
          @send_moderate.moderated_at = Time.now
          @send_moderate.save!
          # 決裁結果を更新
          @send_matter.moderate_result = 1
          @send_matter.sent_at = Time.now
          @send_matter.save!
          flash[:notice] = "決裁が完了しました"
          if @attachments.select{ |attachment|
              attachment.virus_check == '0'}.size > 0
            @receivers.each do |receiver|
              full_url_dl = port + "://" + $app_env['URL'] +
                      "/file_receive/login/" +
                      "#{receiver.url}"
              Notification.send_report(@send_matter, receiver,
                                       @attachments,full_url_dl).deliver
              if @send_matter.password_notice == 1
                Notification.send_password_report(@send_matter, receiver,
                                         @attachments,full_url_dl).deliver
              end
            end
          end
          url_dl = port + "://" + $app_env['URL']
          Notification.send_result_report(@send_matter,
                                          @receivers, @attachments,
                                          url_dl).deliver
        else
          @send_moderater.result = 1
          @send_moderater.save!
          # 次の決裁者へ
          @next_moderater =
              SendModerater
              .where(["send_moderate_id = ?",
                      "number = ?"].join(" AND "),
                      @send_moderate.id, moderater_count).first
          if @next_moderater.present?
            url = port + "://" + $app_env['URL']
            Notification
                .send_matter_moderate_report(@send_matter, @next_moderater,
                    @next_moderater.user, url).deliver
            @next_moderater.send_flag = 1
            @next_moderater.save
            flash[:notice] = "決裁が完了しました"
          else
            @receivers.each do |receiver|
              full_url_dl = port + "://" + $app_env['URL'] +
                      "/file_receive/login/" +
                      "#{receiver.url}"
              Notification.send_report(@send_matter, receiver,
                                       @attachments,full_url_dl).deliver
              if @send_matter.password_notice == 1
                Notification.send_password_report(@send_matter, receiver,
                                         @attachments,full_url_dl).deliver
              end
            end
            url_dl = port + "://" + $app_env['URL']
            Notification.send_result_report(@send_matter,
                                            @receivers, @attachments,
                                            url_dl).deliver
            flash[:notice] = "決裁が完了しました"
          end
        end
      # 簡易決裁
      else
          # 決裁終了
          @send_moderater.result = 1
          @send_moderater.save!
          @send_moderate.result = 1
          @send_moderate.moderated_at = Time.now
          @send_moderate.save!
          # 決裁結果を更新
          @send_matter.moderate_result = 1
          @send_matter.sent_at = Time.now
          @send_matter.save!
          flash[:notice] = "決裁が完了しました"
          if @attachments.select{ |attachment|
              attachment.virus_check == '0'}.size > 0
            @receivers.each do |receiver|
              full_url_dl = port + "://" + $app_env['URL'] +
                      "/file_receive/login/" +
                      "#{receiver.url}"
              Notification.send_report(@send_matter, receiver,
                                       @attachments,full_url_dl).deliver
              if @send_matter.password_notice == 1
                Notification.send_password_report(@send_matter, receiver,
                                         @attachments,full_url_dl).deliver
              end
            end
          end
          url_dl = port + "://" + $app_env['URL']
          Notification.send_result_report(@send_matter,
                                          @receivers, @attachments,
                                          url_dl).deliver
          flash[:notice] = "決裁が完了しました"
      end
    end
    redirect_to :action => :message
  end

  def create
    @send_moderater = SendModerater.find(:first,
            :conditions => {:url => params[:id]})
    @send_moderate = @send_moderater.send_moderate
    @send_matter = @send_moderate.send_matter
    @send_moderaters = @send_moderate.send_moderaters
    port = get_port()
    ActiveRecord::Base.transaction do
      @send_moderater.result = 2
      @send_moderater.content = params[:send_modertaer][:content]
      @send_moderater.save!

      @send_moderate.result = 2
      @send_moderate.moderated_at = Time.now
      @send_moderate.save!
      # 決裁結果を更新
      @send_matter.moderate_result = 2
      @send_matter.save!
    end
    port = get_port()
    url = port + "://" + $app_env['URL']
    Notification.send_matter_moderate_result_report(@send_matter,
                                    @send_moderate,
                                    url).deliver
    flash[:notice] = "決裁が完了しました"
    redirect_to :action => :message
  end

  def message
  end

  private

  def check_auth
    if current_user.present?
      @send_moderater = SendModerater.find(:first, :conditions => {:url => params[:id], :send_flag => 1})
      @moderate_user = @send_moderater.user
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

  def url_check_for_send_moderater
    @send_moderater = SendModerater.find(:first, :conditions => {:url => params[:id]})
    unless @send_moderater.present? && @send_moderater.send_flag == 1
      flash[:notice] = "不正なアクセスかURLが間違っております。"
      redirect_to :action => :message
      return
    end
  end

  def authorize_for_send_moderater
    @send_moderater = SendModerater.find(:first, :conditions => {:url => params[:id], :send_flag => 1})
    @moderate_user = @send_moderater.moderater.user
    login_user = User.find(:first,
          :conditions => {:id => session[:user_id].to_i})
    if @moderate_user == nil || @send_moderater.send_flag == 0
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
