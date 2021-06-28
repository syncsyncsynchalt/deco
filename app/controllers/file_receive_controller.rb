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

class FileReceiveController < ApplicationController
  before_filter :load_env

  # ログイン画面(メールのリンクはここに飛ぶ)
  def login
    session[:auth] = nil
    session[:site_category] = "file_receive"
    @receiver = Receiver.find(:first, :conditions => { :url => params['id']})
    @send_matter = @receiver.send_matter
    session[:receiver_id] = params['id']
    unless flash[:notice]
      flash[:notice] = "#{ @receiver.name }様，#{ @send_matter.name }さんから
                          ファイルを預かっています。"
    end
  end

  # ログインチェック
  def auth
    @receiver = Receiver.find(:first, :conditions =>
                              { :url => session[:receiver_id]})
    @send_matter = SendMatter.find(@receiver.send_matter_id)
    if @send_matter.receive_password == params[:login]['receive_password']
      session[:auth] = { "send_matter_id" => @receiver.send_matter_id,
        "receiver_id" => @receiver.id }
      redirect_to :action => "index"
    else
      flash[:notice] = "パスワードが違います。"
      redirect_to :action => 'login', :params => { :id => @receiver.url }
    end
  end

  # ファイル受け取り画面
  def index
    if session[:auth] && session[:site_category] == "file_receive"
      @send_matter = SendMatter.find(session[:auth]['send_matter_id'])
      if (Time.now - (Time.parse(@send_matter.created_at.to_s) +
                      @send_matter.file_life_period)) > 0
        flash[:notice] = "ファイルの保管期限を過ぎましたので削除されました。"
        redirect_to :action => 'message'
      else
        @receiver = Receiver.find(session[:auth]['receiver_id'])
        @attachments = @send_matter.attachments
        flash[:notice] = "#{ @receiver.name }様，#{ @send_matter.name }さんから
                            ファイルを預かっています。"
      end
    else
      flash[:notice] = "不正なアクセスです。
                        (ログインしていないか別のウィンドウで使用中です。)"
      redirect_to :action => 'login', :params =>
        { :id => session[:receiver_id] }
    end
  end

  # ファイルのダウンロード
  def get
    if session[:auth] && session[:site_category] == "file_receive"
      @attachment = Attachment.find(params[:id])
      if @attachment.send_matter_id == session[:auth]['send_matter_id'] &&
          @attachment.virus_check == '0'
        @send_matter = SendMatter.find(session[:auth]['send_matter_id'])
        if (Time.now - (Time.parse(@send_matter.created_at.to_s) +
                        @send_matter.file_life_period)) > 0
          flash[:notice] = "ファイルの保管期限を過ぎましたので削除されました。"
          redirect_to :action => 'illegal' and return
        else
          @file_dl_check = FileDlCheck.find(:first, :conditions =>
                                   ["receiver_id = ? AND attachment_id = ?",
                                    session[:auth]['receiver_id'],
                                    @attachment.id] )
          if @send_matter.download_check == 1 &&
              @file_dl_check.download_flg == 0
            @receiver = Receiver.find(session[:auth]['receiver_id'])
            @mail = Notification.deliver_receive_report(@send_matter,
                                                        @receiver,
                                                        @attachment)
          end
          @file_dl_check.download_flg = 1
          @file_dl_check.save
          @file_dl_log = FileDlLog.new
          @file_dl_log.file_dl_check = @file_dl_check
          @file_dl_log.save
          if request.user_agent =~ /Windows/i
            @filename = @attachment.name.tosjis
          elsif request.user_agent =~ /Mac/i
            @filename = @attachment.name
          else
            @filename = @attachment.name
          end
          send_file $app_env['FILE_DIR'] + "/#{@attachment.id}",
                    :filename => @filename,
                    :type => @attachment.content_type
        end
      else
        flash[:notice] = "不正なアクセスです。" +
          "(ログインしていないか別のウィンドウで使用中です。)"
        redirect_to :action => 'illegal' and return
      end
    else
      flash[:notice] = "不正なアクセスです。" +
        "(ログインしていないか別のウィンドウで使用中です。)"
      redirect_to :action => 'illegal'
    end
  end

  def illegal
    session[:auth] = nil
    session[:site_category] = "file_receive"
  end

  def message
  end
end
