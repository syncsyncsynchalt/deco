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
class RequestedFileReceiveController < ApplicationController
  before_filter :load_env

  # 認証画面(メールのリンク先)
  def login
    @url_code = params[:id]
    @requested_matter = RequestedMatter.find(:first,
            :conditions => { :url => @url_code })
    pass_port = 'pass'

    session[:request_receive_url_code] = @url_code
    if session[:"#{@url_code}"]
      if session[:"#{@url_code}"]['r_auth']
        pass_port = ''
        session[:site_category] = "requested_file_receive"
        redirect_to :action => 'index'
      end
    end
    
    if pass_port == 'pass'
      session[:"#{@url_code}"] = {
              'r_auth' => nil,
              'requested_matter_id' => @requested_matter.id }

      session[:site_category] = "requested_file_receive"
      unless flash[:notice]
        flash[:notice] = "#{ @requested_matter.request_matter.name }様，" +
                "#{ @requested_matter.name }さんから" +
                "ファイルを預かっています。"
      end
    end
  end

  # 認証チェック
  def auth
    @url_code = session[:request_receive_url_code]
    @requested_matter = RequestedMatter.find(:first,
            :conditions => {
              :id => session[:"#{@url_code}"]['requested_matter_id'] })

    if @requested_matter.receive_password == params[:login]['receive_password']
      session[:"#{@url_code}"]['r_auth'] = 'yes'

      redirect_to :action => 'index'
    else
      flash[:notice] = "パスワードが違います。"
      redirect_to :action => 'login',
              :params => { :id => @requested_matter.url }
    end

  end

  # ファイル受け取り画面
  def index
    @url_code = session[:request_receive_url_code]
    if session[:"#{@url_code}"]['r_auth'] == 'yes'

      @requested_matter = RequestedMatter.
              find(session[:"#{@url_code}"]['requested_matter_id'])

      if (Time.now - (Time.parse(@requested_matter.file_up_date.to_s) +
              @requested_matter.file_life_period)) > 0
        flash[:notice] = "ファイルの保管期限を過ぎましたので削除されました。"
        redirect_to :action => 'blank'
      else
        @requested_attachments = RequestedAttachment.find(:all,
                :conditions => {
                  :requested_matter_id =>
                    session[:"#{@url_code}"]['requested_matter_id'] })
      end
    else
      flash[:notice] = "ログインしていません。"
      redirect_to :action => 'blank'
    end
  end

  # ファイルのダウンロード
  def get
    @url_code = session[:request_receive_url_code]
    if session[:"#{@url_code}"]['r_auth'] == 'yes'
      @requested_attachment = RequestedAttachment.find(params[:id])

      if @requested_attachment.requested_matter.id ==
              session[:"#{@url_code}"]['requested_matter_id']
       @requested_matter = RequestedMatter.
               find(session[:"#{@url_code}"]['requested_matter_id'])

        if (Time.now - (Time.parse(@requested_matter.file_up_date.to_s) +
                @requested_matter.file_life_period)) > 0
          flash[:notice] = "ファイルの保管期限を過ぎましたので削除されました。"
          redirect_to :action => 'blank'
        else
          if @requested_matter.download_check == 1
            unless RequestedAttachment.find(:first,
                    :conditions => ["requested_matter_id = ?
                      AND download_flg = ?",
                      session[:"#{@url_code}"]['requested_matter_id'], 1])
              Notification.requested_file_dl_report(
                      @requested_attachment).deliver
            end
          end

          @requested_attachment.download_flg = 1
          @requested_attachment.save

          @requested_file_dl_log = RequestedFileDlLog.new
          @requested_file_dl_log.requested_attachment = @requested_attachment
          @requested_file_dl_log.save

          if request.user_agent =~ /Windows/i
            @filename = @requested_attachment.name.encode("Windows-31J")
          elsif request.user_agent =~ /Mac/i
            @filename = @requested_attachment.name
          else
            @filename = @requested_attachment.name
          end
          send_file $app_env['FILE_DIR'] + "/r#{@requested_attachment.id}",
                    :filename => @filename,
                    :type => @requested_attachment.content_type
        end
      else
        flash[:notice] = "不正なアクセスです（ＩＤが違います）。"
        redirect_to :action => 'blank'
      end
    else
      flash[:notice] = "不正なアクセスです。"
      redirect_to :action => 'blank'
    end
  end

  def blank
  end
end
