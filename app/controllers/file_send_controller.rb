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

class FileSendController < ApplicationController
  protect_from_forgery :except => [:upload]
  before_filter :authorize, :except => [:upload]
  before_filter :load_env
  # 入力フォーム
  def index
    session[:site_category] = nil
    session[:send_matter_id] = nil
    @send_matter = SendMatter.new
    @receiver = Receiver.new
    @attachment = Attachment.new
    @relay_id = generate_random_strings(rand(1000).to_s)
    respond_to do |format|
      format.html
      format.xml { render :xml => @send_file }
    end
  end

  # flashなしメッセージ画面
  def noflash
    flash[:notice] = 'Flash Player がインストールされていないか' +
      '本サービスが利用できないバージョンです。'
  end

  # 入力フォーム flashなし
  def index_noflash
    session[:site_category] = nil
    session[:send_matter_id] = nil
    @send_matter = SendMatter.new
    @receiver = Receiver.new
    @attachment = Attachment.new
    @relay_id = generate_random_strings(rand(1000).to_s)
    respond_to do |format|
      format.html
      format.xml { render :xml => @send_file }
    end
  end

  # アップロード処理
  # render :text => "success!"は、SWFupload のエラー対策
  def upload
    render :text => "success!"
    @attachment = Attachment.new
    @attachment.name = params[:Filename]
    @attachment.size = params[:Filedata].size
    if MIME::Types.type_for(params[:Filedata].original_filename)[0]
      @attachment.content_type = MIME::Types.
        type_for(params[:Filedata].original_filename)[0].content_type
    else
      @attachment.content_type = ''
    end
    @attachment.relayid = params[:Relay_id]
    @attachment.save
    @file = params[:Filedata]
    if @file
      @file.binmode
      File.open($app_env['FILE_DIR'] + "/#{@attachment.id}", "w") do |f|
        f.binmode
        f.write(@file.read)
      end
    end
    @attachment.virus_check = '0'
    @attachment.save
  end

  # SendMatter, Receiverへの書き込み
  def create
    if session[:send_matter_id]
      flash[:notice] = '既に送信完了しています。
       （ブラウザの「戻る」ボタンを押してからの送信は無効です）'
      redirect_to :action => 'result'
    else
      @send_matter = SendMatter.new(params[:send_matter])
      @send_matter.url = generate_random_strings(rand(1000).to_s)
      @send_matter.status = 1
      @attachments = Attachment.find(:all, :conditions =>
                                     {:relayid => @send_matter.relayid})
      if @attachments.length < 1
        flash[:notice] = '送信失敗しました。もう一度送信してください。'
          redirect_to :action => 'send_ng' and return
      end
      ActiveRecord::Base.transaction do
        @attachments.each do |attachment|
          attachment.send_matter = @send_matter
          attachment.save!
        end
        params[:receiver].each do |key, value|
          @receiver = Receiver.new(value)
          @receiver.send_matter = @send_matter
          @receiver.url = generate_random_strings(@receiver.name)
          @receiver.save!
          @send_matter.attachments.each do |attachment|
            @file_dl_check = FileDlCheck.new
            @file_dl_check.receiver = @receiver
            @file_dl_check.attachment = attachment
            @file_dl_check.download_flg = 0
            @file_dl_check.save!
          end
        end
        @send_matter.save!
      end
      session[:send_matter_id] = @send_matter.id
      flash[:notice] = 'ファイル送信を完了しました。'
      redirect_to :action => 'result'
      @receivers = @send_matter.receivers
      if @attachments.select{ |attachment|
          attachment.virus_check == '0'}.size > 0
        @receivers.each do |receiver|
          full_url_dl = "http://" + $app_env['URL'] +
                  "/file_receive/login/" +
                  "#{receiver.url}"
          @mail = Notification.deliver_send_report(@send_matter, receiver,
                                                   @attachments,full_url_dl)
        end
      end
      @mail = Notification.deliver_send_result_report(@send_matter,
                                                      @receivers, @attachments)
    end
  end

  # flashなし版のファイル送信，SendMatter, Receiverへの書き込み
  def create_noflash
    if session[:send_matter_id]
      flash[:notice] = '既に送信完了しています。
       （ブラウザの「戻る」ボタンを押してからの送信は無効です）'
      redirect_to :action => 'result'
    else
      @send_matter = SendMatter.new(params[:send_matter])
      @send_matter.url = generate_random_strings(rand(1000).to_s)
      @send_matter.status = 1
      @total_file_size = 0
      params[:attachment].each do |key, value|
        if value[:file].size > ($app_env['FILE_SIZE_LIMIT'].to_i)*1024*1024
          flash[:notice] = 'ファイルサイズが制限を越えています。'
          redirect_to :action => 'result_ng' and return
        end
        @total_file_size += value[:file].size
        if @total_file_size >
            ($app_env['FILE_TOTAL_SIZE_LIMIT'].to_i)*1024*1024
          flash[:notice] = 'ファイルの合計サイズが制限を越えています。'
          redirect_to :action => 'result_ng' and return
        end
      end

      ActiveRecord::Base.transaction do
        params[:attachment].each do |key, value|
          @attachment = Attachment.new
          @attachment.send_matter = @send_matter
          @attachment.name = value[:file].original_filename
          @attachment.size = value[:file].size
          if (MIME::Types.type_for(value[:file].original_filename)[0])
            @attachment.content_type = MIME::Types.
              type_for(value[:file].original_filename)[0].content_type
          else
            @attachment.content_type = ''
          end
          @attachment.relayid = 0
          @attachment.save!
          value[:file].binmode
          File.open($app_env['FILE_DIR'] + "/#{@attachment.id}", "w") do |f|
            f.binmode
            f.write(value[:file].read)
          end
          @attachment.virus_check = '0'
          @attachment.save!
        end

        params[:receiver].each do |key, value|
          @receiver = Receiver.new(value)
          @receiver.send_matter = @send_matter
          @receiver.url = generate_random_strings(@receiver.name)
          @receiver.save!

          @send_matter.attachments.each do |attachment|
            @file_dl_check = FileDlCheck.new
            @file_dl_check.receiver = @receiver
            @file_dl_check.attachment = attachment
            @file_dl_check.download_flg = 0
            @file_dl_check.save!
          end
        end
        @send_matter.save!
      end
      session[:send_matter_id] = @send_matter.id
      flash[:notice] = 'ファイル送信を完了しました。'
      redirect_to :action => 'result'
      @receivers = @send_matter.receivers
      @attachments = @send_matter.attachments

      if @attachments.select{ |attachment|
          attachment.virus_check == '0' }.size > 0
        @receivers.each do |receiver|
          full_url_dl = "http://" + $app_env['URL'] +
                  "/file_receive/login/" +
                  "#{receiver.url}"
          @mail = Notification.deliver_send_report(@send_matter, receiver,
                                                   @attachments,full_url_dl)
        end
      end

      @mail = Notification.deliver_send_result_report(@send_matter,
                                                      @receivers, @attachments)
    end
  end

  def result
    session[:site_category] = nil
    if params[:id]
      @send_matter = SendMatter.find(:first, :conditions =>
                                     { :url => params['id'] })
      session[:send_matter_id] = @send_matter.id
    else
      @send_matter = SendMatter.find(session[:send_matter_id])
    end

    if (Time.now - (Time.parse(@send_matter.created_at.to_s) +
                    @send_matter.file_life_period)) > 0
      flash[:notice] = "ファイルの保管期限を過ぎましたので削除されました。"
      redirect_to :action => "result_ng"
    end
    @receivers = @send_matter.receivers
    @attachments = @send_matter.attachments
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "不正なアクセスです。
                     （アクセスの集中，ブラウザの操作上の問題が考えられます。）"
    redirect_to :action => "result_ng"
  end

  def result_ng
  end

  def send_ng
  end

  # result アクションからの削除
  def delete
    @send_matter = SendMatter.find(session[:send_matter_id])
    @attachment = Attachment.find(params[:id])
    @receivers = @send_matter.receivers
    if @attachment.send_matter_id == session[:send_matter_id]
      @attachment.destroy
      @receivers.each do |receiver|
        @mail = Notification.deliver_file_delete_report(@send_matter,
                                                        receiver,
                                                        @attachment)
      end

      @mail = Notification.deliver_file_delete_result_report(@send_matter,
                                                             @receivers,
                                                             @attachment)
      flash[:notice] = "#{@attachment.name} を削除しました。"
      redirect_to(:action => "result")
    else
      redirect_to(:action => "illigal")
    end
  end
end
