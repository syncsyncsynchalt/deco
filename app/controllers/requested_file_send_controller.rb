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
class RequestedFileSendController < ApplicationController
  protect_from_forgery :except => [:upload]
  before_filter :load_env

  def blank
  end

  # 認証画面(メールのリンク先)
  def login
    @url_code = params[:id]
    @requested_matter = RequestedMatter.find(:first,
                                        :conditions => { :url => @url_code })
    pass_port = 'pass'
    if @requested_matter.file_up_date
      flash[:notice] = "送信ありがとうございました"
      redirect_to :action => 'blank'
    else
      session[:request_send_url_code] = @url_code
      if session[:"#{@url_code}"]
        if session[:"#{@url_code}"]['auth']
          pass_port = ''
          session[:site_category] = session[:"#{@url_code}"]['site_category']
          redirect_to :action => 'index'
        end
      end

      if pass_port == 'pass'
        session[:"#{@url_code}"] = {'auth' => nil,
            'site_category' => "requested_file_send",
            'requested_matter_id' => @requested_matter.id }

        session[:site_category] = session[:"#{@url_code}"]['site_category']
        unless flash[:notice]
          flash[:notice] = "#{ @requested_matter.name }様、" +
              "#{ @requested_matter.request_matter.name }さんから" +
              "ファイルの送信依頼が来ております。"
        end
      end
    end
  end

  # 認証チェック
  def auth
    @url_code = session[:request_send_url_code]
    @requested_matter = RequestedMatter.find(:first,
            :conditions => {
              :id => session[:"#{@url_code}"]['requested_matter_id'] })

    if @requested_matter.send_password == params[:login]['send_password']
      if @requested_matter.request_matter.sent_at.present?
        if (Time.now - (Time.parse(@requested_matter.request_matter.sent_at.to_s) +
                $app_env['REQUEST_PERIOD'].to_i)) > 0
          @request_send_flag = false
        else
          @request_send_flag = true
        end
      elsif @send_matter.moderate_flag == nil
        if (Time.now - (Time.parse(@requested_matter.request_matter.created_at.to_s) +
                $app_env['REQUEST_PERIOD'].to_i)) > 0
          @request_send_flag = false
        else
          @request_send_flag = true
        end
      else
        @request_send_flag = false
      end
      if @request_send_flag == true
        session[:"#{@url_code}"]['auth'] = "yes"
        redirect_to :action => 'index'
      else
        flash[:notice] = "ファイルの送信依頼期限を過ぎています。"
        redirect_to :action => 'blank'
      end
    else
      flash[:notice] = "パスワードが違います。"
      redirect_to :action => 'login', :params =>
              { :id => @requested_matter.url }
    end
  end

  # 依頼送信フォーム画面
  def  index
    @url_code = session[:request_send_url_code]
    if session[:"#{@url_code}"]['auth'] == 'yes'
      @file_life_periods = AppEnv.find(:all,
              :conditions => { :key => "FILE_LIFE_PERIOD" },
              :order => 'id ASC' )

      @requested_matter = RequestedMatter.find(:first,
              :conditions => {
                :id => session[:"#{@url_code}"]['requested_matter_id'] })

      if @requested_matter.file_up_date
        flash[:notice] = "すでに送信していただいてます"
        redirect_to :action => 'blank'
      else
        password_length = $app_env['PW_LENGTH_MIN'].to_i +
          ($app_env['PW_LENGTH_MAX'].to_i - $app_env['PW_LENGTH_MIN'].to_i) / 2
        @randam_password =
            generate_random_string_values(rand(10000).to_s).slice(1,password_length)
        respond_to do |format|
          format.html
          format.xml { reander :xml => @requested_file_send }
        end
      end
    else
      flash[:notice] = "ログインしていません"
      redirect_to :action => 'blank'
    end
  end

  # flashなしメッセージ画面
  def noflash
    flash[:notice] = 'Flash Player がインストールされていないか本サービスが
                      利用できないバージョンです。'
  end

  # 入力フォーム flashなし
  def  index_noflash
    @url_code = session[:request_send_url_code]
    if session[:"#{@url_code}"]['auth'] == 'yes'
      @file_life_periods = AppEnv.find(:all,
              :conditions => { :key => "FILE_LIFE_PERIOD" },
              :order => 'id ASC' )

      @requested_matter = RequestedMatter.find(:first,
              :conditions => {
              :id => session[:"#{@url_code}"]['requested_matter_id'] })

      if @requested_matter.file_up_date
        flash[:notice] = "すでに送信していただいてます"
        redirect_to :action => 'blank'
      else
        password_length = $app_env['PW_LENGTH_MIN'].to_i +
          ($app_env['PW_LENGTH_MAX'].to_i - $app_env['PW_LENGTH_MIN'].to_i) / 2
        @randam_password =
            generate_random_string_values(rand(10000).to_s).slice(1,password_length)
        respond_to do |format|
          format.html
          format.xml { reander :xml => @requested_file_send }
        end
      end
    else
      flash[:notice] = "ログインしていません"
      redirect_to :action => 'blank'
    end
  end


  # ファイルのアップロード
  def upload
    @requested_matter =
        RequestedMatter
        .where("id = ?", params[:Requested_Matter_id])
        .first

    session[:request_send_url_code] = @requested_matter.url

    unless @requested_matter.file_up_date
      render :text => "success!"

      ActiveRecord::Base.transaction do
        @requested_attachment = RequestedAttachment.new()
        @requested_attachment.name = params[:Filename]
        @requested_attachment.size = params[:Filedata].size
        @requested_attachment.requested_matter_id = @requested_matter.id
        @requested_attachment.download_flg = 0
        @requested_attachment.save!
        @file = params[:Filedata]
        if @file
          File.open($app_env['FILE_DIR'] +
                  "/r#{@requested_attachment.id}", "w") do |f|
            f.binmode
            f.write(@file.read)
          end
        end
        if MimeMagic.by_magic(File.open($app_env['FILE_DIR'] +
                                        "/r#{@requested_attachment.id}"))
          @requested_attachment.content_type =
              MimeMagic.by_magic(File.open($app_env['FILE_DIR'] +
                                         "/r#{@requested_attachment.id}")).type
        else
          @requested_attachment.content_type = ''
        end
        @requested_attachment.save!
        if $app_env['VIRUS_CHECK'] == '1'
          # Virus Check
          @clamav = ClamAV.instance
          @clamav.loaddb()
          @virus_check_result = @clamav.scanfile($app_env['FILE_DIR'] +
                  "/r#{@requested_attachment.id}")
          @requested_attachment.virus_check = @virus_check_result
          @requested_attachment.save!
          if(@virus_check_result != 0)
            File.delete($app_env['FILE_DIR'] + "/r#{@requested_attachment.id}")
          end
        else
          @attachment.virus_check = '0'
          @attachment.save
        end
      end
    end
  end

  # 依頼送信に関連するカラムの作成
  def create
    @requested_matter = RequestedMatter.find(:first,
            :conditions => { :id => params[:requested_matter_id] })

    @url_code =params[:requested_matter_url]

    if session[:"#{@url_code}"]['requested_matter_id'] ==
            @requested_matter.id
      session[:request_send_url_code] = @requested_matter.url

      if @requested_matter.file_up_date
        flash[:notice] = "すでに送信しております"
        redirect_to :action => 'blank'
      else
        @requested_attachments = RequestedAttachment.find(:all,
                :conditions => {
                  :requested_matter_id =>
                    session[:"#{@url_code}"]['requested_matter_id'] })

        if @requested_attachments.length < 1
          flash[:notice] = "送信失敗しました。もう一度送信してください。"
          redirect_to :action => 'send_ng'
        else
          ActiveRecord::Base.transaction do
            @virus_attachments = Array.new
            @requested_attachments.each do |attachment|
              unless attachment.virus_check == '0'
                @virus_attachments.push attachment
              end
            end
            @requested_matter.update_attributes(params[:requested_matter])
            @requested_matter.url_operation =
                    generate_random_strings(@requested_matter.name)
            @requested_matter.file_up_date = DateTime.now
            @requested_matter.save!

            unless @requested_matter.save!
              render :action => 'index'
            end

            redirect_to :action => 'result',
                    :id => @requested_matter.url_operation
          end

          port = get_port()
          full_url_dl = port + "://" + $app_env['URL'] +
                  "/requested_file_receive/login/" +
                  "#{@requested_matter.url}"
          full_url_check = port + "://" + $app_env['URL'] +
                  "/requested_file_send/result/" +
                  "#{@requested_matter.url_operation}"

          if @requested_attachments.select{ |requested_attachment|
                  requested_attachment.virus_check == '0' }.size > 0
            Notification.requested_send_report(
                    @requested_matter,
                    @requested_attachments,
                    full_url_dl).deliver
            if @requested_matter.password_notice == 1
              Notification.requested_send_password_report(
                      @requested_matter,
                      @requested_attachments,
                      full_url_dl).deliver
            end
          end

          if @virus_attachments.length > 0
            if $app_env['VIRUS_CHECK_NOTICE'] == '1'
              @admin_users =
                  User.find(:all, :conditions =>
                  {:category => 1})
              for user in @admin_users
                Notification.requested_send_virus_info_report(
                        @requested_matter, @virus_attachments, user).deliver
              end
            end
          end

          Notification.requested_send_copied_report(
                  @requested_matter,
                  @requested_attachments,
                  full_url_dl,
                  full_url_check, $app_env['PASSWORD_AUTOMATION'].to_i).deliver
        end
      end
    else
      flash[:notice] = "不正なアクセスです"
      redirect_to :action => 'blank'
    end
  end

  def create_noflash
    @requested_matter = RequestedMatter.find(:first,
            :conditions => { :id => params[:requested_matter_id] })

    @url_code =params[:requested_matter_url]

    if session[:"#{@url_code}"]['requested_matter_id'] ==
            @requested_matter.id
      session[:request_send_url_code] = @requested_matter.url

      if @requested_matter.file_up_date
        flash[:notice] = "すでに送信しております"
        redirect_to :action => 'blank'
      else
        @requested_attachments = RequestedAttachment.find(:all,
                :conditions => {
                  :requested_matter_id =>
                    session[:"#{@url_code}"]['requested_matter_id'] })
          @total_file_size = 0

          params[:attachment].each do |key, value|
            if value[:file].size >
                    ($app_env['FILE_SIZE_LIMIT'].to_i)*1024*1024
              flash[:notice] = 'ファイルサイズが制限を越えています。'
              redirect_to :action => 'blank' and return
            end
            @total_file_size += value[:file].size
            if @total_file_size >
                    ($app_env['FILE_TOTAL_SIZE_LIMIT'].to_i)*1024*1024
              flash[:notice] = 'ファイルの合計サイズが制限を越えています。'
              redirect_to :action => 'blank' and return
            end
          end

          ActiveRecord::Base.transaction do
            @virus_attachments = Array.new

            @requested_matter.update_attributes(params[:requested_matter])
            @requested_matter.url_operation =
                    generate_random_strings(@requested_matter.name)
            @requested_matter.file_up_date = DateTime.now
            @requested_matter.status = 1
            @requested_matter.save!

            params[:attachment].each do |key, value|

              @requested_attachment = RequestedAttachment.new()
              @requested_attachment.name = value[:file].original_filename
              @requested_attachment.size = value[:file].size
              @requested_attachment.download_flg = 0
              @requested_attachment.requested_matter_id = @requested_matter.id
              @requested_attachment.save!

              File.open($app_env['FILE_DIR'] +
                      "/r#{@requested_attachment.id}", "w") do |f|
                f.binmode
                f.write(value[:file].read)
              end
              if MimeMagic.by_magic(File.open($app_env['FILE_DIR'] +
                                              "/r#{@requested_attachment.id}"))
                @requested_attachment.content_type =
                    MimeMagic.by_magic(File.open($app_env['FILE_DIR'] +
                                                 "/r#{@requested_attachment.id}")).type
              else
                @requested_attachment.content_type = ''
              end
              @requested_attachment.save!
              if $app_env['VIRUS_CHECK'] == '1'
                # Virus Check
                @clamav = ClamAV.instance
                @clamav.loaddb()
                @virus_check_result = @clamav.scanfile($app_env['FILE_DIR'] +
                        "/r#{@requested_attachment.id}")
                @requested_attachment.virus_check = @virus_check_result
                @requested_attachment.save!
                unless @virus_check_result == 0
                  File.delete($app_env['FILE_DIR'] +
                          "/r#{@requested_attachment.id }")
                  @virus_attachments.push @requested_attachment
                end
              else
                @requested_attachment.virus_check = '0'
                @requested_attachment.save!
              end
            end
          end

          redirect_to :action => 'result',
                  :id => @requested_matter.url_operation

          @requested_attachments = @requested_matter.requested_attachments

          port = get_port()
          full_url_dl = port + "://" + $app_env['URL'] +
                  "/requested_file_receive/login/" +
                  "#{@requested_matter.url}"
          full_url_check = port + "://" + $app_env['URL'] +
                  "/requested_file_send/result/" +
                  "#{@requested_matter.url_operation}"

          if @requested_attachments.select{ |requested_attachment|
                  requested_attachment.virus_check == '0' }.size > 0
            Notification.requested_send_report(
                    @requested_matter,
                    @requested_attachments,
                    full_url_dl).deliver
            if @requested_matter.password_notice == 1
              Notification.requested_send_password_report(
                      @requested_matter,
                      @requested_attachments,
                      full_url_dl).deliver
            end
          end

          if @virus_attachments.length > 0
            if $app_env['VIRUS_CHECK_NOTICE'] == '1'
              @admin_users =
                  User.find(:all, :conditions =>
                  {:category => 1})
              for user in @admin_users
                Notification.requested_send_virus_info_report(
                        @requested_matter, @virus_attachments, user).deliver
             end
            end
          end

          Notification.requested_send_copied_report(
                  @requested_matter,
                  @requested_attachments,
                  full_url_dl,
                  full_url_check, $app_env['PASSWORD_AUTOMATION'].to_i).deliver
      end
    else
      flash[:notice] = "不正なアクセスです"
      redirect_to :action => 'blank'
    end
  end

  # 依頼送信結果
  def result
    session[:requested_matter_id] = nil
    if session[:request_send_url_code]
      @url_code = session[:request_send_url_code]
       session[:requested_matter_id] =
               session[:"#{@url_code}"]['requested_matter_id']
      @requested_matter = RequestedMatter.find(session[:requested_matter_id])
    elsif params[:id]
      @requested_matter = RequestedMatter.find(:first,
                          :conditions => {
                            :url_operation => params['id'] })
      session[:requested_matter_id] = @requested_matter.id
    end

    if session[:requested_matter_id]
      @requested_attachments = RequestedAttachment.find(:all,
              :conditions => {
                :requested_matter_id => session[:requested_matter_id] })
    else
      flash[:notice] = "不正なアクセスです"
      redirect_to(:action => "blank")
    end
  end

  # result アクションからの削除
  def delete
    session[:requested_matter_id] = nil
    if session[:request_send_url_code]
      @url_code = session[:request_send_url_code]
       session[:requested_matter_id] =
               session[:"#{@url_code}"]['requested_matter_id']
    end

    if session[:requested_matter_id]
      @requested_matter = RequestedMatter.find(session[:requested_matter_id])
      @attachment = RequestedAttachment.find(params[:id])
      if @attachment
        if @attachment.requested_matter_id == session[:requested_matter_id]
          @attachment.destroy

          port = get_port()
          url = port + "://" + $app_env['URL']
          Notification.requested_file_delete_report(
                  @requested_matter, @attachment).deliver

          Notification.requested_file_delete_copied_report(
                  @requested_matter, @attachment, url).deliver

          flash[:notice] = "#{@attachment.name} を削除しました。"
          redirect_to(:action => "result")
        else
          flash[:notice] = "不正なアクセスです"
          redirect_to(:action => "blank")
        end
      else
        flash[:notice] = "#{@attachment.name} はすでに削除されています。"
        redirect_to(:action => "result")
      end
    else
      flash[:notice] = "不正なアクセスです"
      redirect_to(:action => "blank")
    end
  end

  def send_ng
  end
end
