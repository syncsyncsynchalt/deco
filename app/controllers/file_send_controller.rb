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
class FileSendController < ApplicationController
#  protect_from_forgery :except => [:upload]
#  protect_from_forgery with: :exception
  before_action :authorize, :except => [:upload, :result, :login, :auth, :result_ng]
  before_action :result_id_check, :only => [:result]
  before_action :result_authorize, :only => [:result]
  before_action :load_env
  # 入力フォーム
  def index
    session[:site_category] = nil
    session[:send_matter_id] = nil
    @send_matter = SendMatter.new
    @send_matter.class_eval { attr_accessor :mail_domain }
    @receiver = Receiver.new
    @attachment = Attachment.new
    @relay_id = generate_random_strings(rand(1000).to_s)
    password_length = @params_app_env['PW_LENGTH_MIN'].to_i +
          (@params_app_env['PW_LENGTH_MAX'].to_i - @params_app_env['PW_LENGTH_MIN'].to_i) / 2
    @randam_password =
        generate_random_string_values(rand(10000).to_s, password_length)
    if @params_app_env['PASSWORD_AUTOMATION'] == '1'
      @send_matter.receive_password = @randam_password
    end
    @login_user_exist_flg = 0
    Dir.glob("vendor/engines/*/").each do |path|
      engine = path.split("\/")[2]
      if eval("ApplicationController.method_defined?(:#{engine}_get_user_info)")
        if @login_user_exist_flg == 0
          local_user_info = eval("#{engine}_get_user_info")
          if local_user_info[0] == 1
            @login_user_exist_flg = local_user_info[0]
            @send_matter.name = local_user_info[1]
            @send_matter.mail_address = local_user_info[2]
          end
        end
      end
    end
    if @login_user_exist_flg == 0
      if session[:user_id].present? && current_user.present?
        if current_user.from_organization_add.present?
          @send_matter.name = "#{current_user.from_organization_add}　#{current_user.name}"
        else
          @send_matter.name = "#{current_user.name}"
        end
        if @local_ips.select{ |local_ip| IPAddr.new(local_ip.value).include?(@access_ip) }.size > 0
          count = 0
          for key_word in current_user.email.split(/\@/)
            if count == 0
              @send_matter.mail_address = key_word
            else
              @send_matter.mail_domain = key_word
            end
            count += 1
          end
        else
          @send_matter.mail_address = current_user.email
        end
      end
    end
    respond_to do |format|
      format.html
      format.xml { render :xml => @send_file }
    end
  end

  # 入力フォーム flashなし
  def index_noflash
    index()
  end

  # アップロード処理
  def upload5
    begin
      file = params[:myfile]
      is_ie = false
      if request.xhr?
        file_data = file.tempfile.read
        file_name = file.original_filename
        file_content_type = file.content_type
      else
        if file.instance_of?(File)
          file_data = file.read
          file_name = file.original_filename
        else
          is_ie = true
          file_data = file.tempfile.read
          file_name = file.original_filename
        end
      end

      server_directory = @params_app_env['FILE_DIR']
      if !File.exists?(server_directory)
        raise "upload failure"
      elsif !File.directory?(server_directory)
        raise "upload failure"
      end

      tmp_path = @params_app_env['FILE_DIR'] if file_data
      raise "upload failure" unless file_data

      @attachment = Attachment.new
      @attachment.name = file_name
      @attachment.size = file_data.size
      @attachment.save

      FileUtils.mkdir_p(tmp_path) unless FileTest.exist?(tmp_path)
      file_path = "#{tmp_path}/#{@attachment.id}"
      File.open(file_path, "w") do |f|
        f.binmode
        f.write(file_data)
      end

      if file.content_type.blank?
        if MIME::Types.type_for(params[:Filedata].original_filename)[0].content_type
          @attachment.content_type = MIME::Types.type_for(params[:Filedata].original_filename)[0].content_type
        else
          @attachment.content_type = ''
        end
      else
        @attachment.content_type = file.content_type
      end
      @attachment.relayid = params[:relay_id]
      @attachment.file_save_pass = file_path
      @attachment.save
      if @params_app_env['VIRUS_CHECK'] == '1'
        # Virus Check
        @virus_check_result = get_virus_status(file_path)
        @attachment.virus_check = @virus_check_result
        @attachment.save
        if @virus_check_result != '0'
          if File.exist?(file_path)
            File.delete(file_path)
          end
        end
      else
        @attachment.virus_check = '0'
        @attachment.save
      end
    rescue
      render :json => { :error => file_name, :id => "00000" }
    else
      if is_ie
        render :plain => %{<textarea id="upload_result">{ success:true, id:"", description:""}</textarea>}
      else
        render :json => { :success => true, :size => file_data.size }
      end
    end
  end

  # SendMatter, Receiverへの書き込み
  def create
    if session[:send_matter_id]
      flash[:notice] = '既に送信完了しています。
       （ブラウザの「戻る」ボタンを押してからの送信は無効です）'
      redirect_to :action => 'result'
    else
#      @attachments = Attachment.find(:all, :conditions => {:relayid => @send_matter.relayid})
      @send_matter = SendMatter.new(post_params_send_matters)
      @send_matter.url = generate_random_strings(rand(1000).to_s)
      @send_matter.status = 1
      if params[:mail_domain].present?
        @send_matter.mail_address += '@' + params[:mail_domain]
      end
      if session[:user_id].present? && current_user.present?
        @send_matter.user = current_user
      end
      @attachments =
          Attachment
          .where(:relayid => @send_matter.relayid)
      if @attachments.length < 1
        flash[:notice] = '送信失敗しました。もう一度送信してください。'
          redirect_to :action => 'send_ng' and return
      end
      @virus_down_attachments = Array.new
      @virus_error_attachments = Array.new
      @attachments.each do |attachment|
        unless attachment.virus_check == '0' ||
           attachment.virus_check == nil
          if attachment.virus_check == t("virus_check_status.virus_check_down")
            @virus_down_attachments.push attachment
          elsif attachment.virus_check == t("virus_check_status.error")
            @virus_error_attachments.push attachment
          end
        end
      end
      if @attachments.length == @virus_down_attachments.length
        flash[:notice] = 'ウィルスチェック機能が正常に動作していません。'
          redirect_to :action => 'send_ng2' and return
      elsif @attachments.length == @virus_error_attachments.length
        flash[:notice] = '送信失敗しました。もう一度送信してください。'
          redirect_to :action => 'send_ng' and return
      end

#      ActiveRecord::Base.transaction do
#        @send_matter.save!
#        @virus_attachments = Array.new
#        @attachments.each do |attachment|
#          attachment.send_matter = @send_matter
#          attachment.save!
#          unless attachment.virus_check == '0' ||
#             attachment.virus_check == nil
#            @virus_attachments.push attachment
#          end
#        end
#        params[:receiver].each do |key, value|
#          @receiver = Receiver.new(receivers_params(value))
#          @receiver.send_matter = @send_matter
#          @receiver.url = generate_random_strings(@receiver.name)
#          @receiver.save!
#          @send_matter.attachments.each do |attachment|
#            @file_dl_check = FileDlCheck.new
#            @file_dl_check.receiver = @receiver
#            @file_dl_check.attachment = attachment
#            @file_dl_check.download_flg = 0
#            @file_dl_check.save!
#          end
#        end
#        if session[:user_id].present? && current_user.present?
#          if current_user.moderate.present?
#            @moderate = current_user.moderate
#            @moderate_flag = 1
#          else
#            @moderate_flag = 0
#          end
#        else
#          @moderate_value =
#              AppEnv
#              .where(["category = ?",
#                      "`key` = ?"].join(" AND "),
#                      0, 'MODERATE_DEFAULT').first
#          if @moderate_value.present?
#            @moderate =
#                Moderate
#                .where("id = ?",
#                       @moderate_value.value).first
#            if @moderate.present?
#              @moderate_flag = 1
#            else
#              @moderate_flag = 0
#            end
#          else
#            @moderate_flag = 0
#          end
#        end
#        if @moderate_flag == 1
#          @send_matter.moderate_flag = 1
#          @send_matter.moderate_result = 0
#          @send_moderate = SendModerate.new()
#          @send_moderate.send_matter = @send_matter
#          @send_moderate.moderate = @moderate
#          @send_moderate.name = @moderate.name
#          @send_moderate.type_flag = @moderate.type_flag
#          @send_moderate.result = 0
#          @send_moderate.save!
#          for moderater in @moderate.moderaters
#            send_moderater = SendModerater.new()
#            send_moderater.moderater = moderater
#            send_moderater.send_moderate = @send_moderate
#            send_moderater.user = moderater.user
#            send_moderater.user_name = moderater.user.name
#            send_moderater.number = moderater.number
#            send_moderater.send_flag = 0
#            send_moderater.result = 0
#            send_moderater.url =
#                generate_random_strings(rand(10000).to_s)
#            send_moderater.save!
#          end
#        else
#          @send_matter.moderate_flag = 0
#          @send_matter.moderate_result = 1
#          @send_matter.sent_at = Time.now
#        end
#        @send_matter.save!
#      end

      begin
        ActiveRecord::Base.transaction do
          @send_matter.save!
          @virus_attachments = Array.new
          @attachments.each do |attachment|
            attachment.send_matter = @send_matter
            attachment.save!
            unless attachment.virus_check == '0' ||
               attachment.virus_check == nil
              @virus_attachments.push attachment
            end
          end
          params[:receiver].each do |key, value|
            @receiver = Receiver.new(receivers_params(value))
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
          if session[:user_id].present? && current_user.present?
            if current_user.moderate.present?
              @moderate = current_user.moderate
              @moderate_flag = 1
            else
              @moderate_flag = 0
            end
          else
            @moderate_value =
                AppEnv
                .where(["category = ?",
                        "`key` = ?"].join(" AND "),
                        0, 'MODERATE_DEFAULT').first
            if @moderate_value.present?
              @moderate =
                  Moderate
                  .where("id = ?",
                         @moderate_value.value).first
              if @moderate.present?
                @moderate_flag = 1
              else
                @moderate_flag = 0
              end
            else
              @moderate_flag = 0
            end
          end
          if @moderate_flag == 1
            @send_matter.moderate_flag = 1
            @send_matter.moderate_result = 0
            @send_moderate = SendModerate.new()
            @send_moderate.send_matter = @send_matter
            @send_moderate.moderate = @moderate
            @send_moderate.name = @moderate.name
            @send_moderate.type_flag = @moderate.type_flag
            @send_moderate.result = 0
            @send_moderate.save!
            for moderater in @moderate.moderaters
              send_moderater = SendModerater.new()
              send_moderater.moderater = moderater
              send_moderater.send_moderate = @send_moderate
              send_moderater.user = moderater.user
              send_moderater.user_name = moderater.user.name
              send_moderater.number = moderater.number
              send_moderater.send_flag = 0
              send_moderater.result = 0
              send_moderater.url =
                  generate_random_strings(rand(10000).to_s)
              send_moderater.save!
            end
          else
            @send_matter.moderate_flag = 0
            @send_matter.moderate_result = 1
            @send_matter.sent_at = Time.now
          end
          @send_matter.save!
        end
      rescue => e
        logger.error "#{e.class} (#{e.message}):\n#{Rails.backtrace_cleaner.clean(e.backtrace).join("\n").indent(1)}"
        flash[:notice] = '送信失敗しました。もう一度送信してください。'
        redirect_to :action => 'send_ng' and return
      end
    
      session[:send_matter_id] = @send_matter.id
      redirect_to :action => 'result'
      @receivers = @send_matter.receivers
      port = get_port()
      if @moderate_flag == 1
        if @send_moderate.type_flag == 0
          @send_moderater =
              SendModerater
              .where(["send_moderate_id = ?",
                      "number = 1"].join(" AND "),
                     @send_moderate.id).first
            url = port + "://" + @params_app_env['URL']
            Notification
                .send_matter_moderate_report(@send_matter, @send_moderater,
                    @send_moderater.user, url).deliver
          @send_moderater.send_flag = 1
          @send_moderater.save
        else
          @send_moderaters =
              SendModerater
              .where("send_moderate_id = ?",
                     @send_moderate.id)
          for send_moderater in @send_moderaters
            url = port + "://" + @params_app_env['URL']
            Notification
                .send_matter_moderate_report(@send_matter, send_moderater,
                    send_moderater.user, url).deliver
            send_moderater.send_flag = 1
            send_moderater.save
          end
        end
        url = port + "://" + @params_app_env['URL']
        Notification
            .send_matter_moderate_copied_report(@send_matter, @send_moderate,
                url).deliver
      else
        flash[:notice] = 'ファイル送信を完了しました。'
        if @attachments.select{ |attachment|
            (attachment.virus_check == '0' ||
             attachment.virus_check == nil)}.size > 0
          @receivers.each do |receiver|
            full_url_dl = port + "://" + @params_app_env['URL'] +
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
        url_dl = port + "://" + @params_app_env['URL']
        Notification.send_result_report(@send_matter,
                                        @receivers, @attachments,
                                        url_dl).deliver
      end
        if @virus_attachments.length > 0
          if @params_app_env['VIRUS_CHECK_NOTICE'] == '1'
#            @admin_users = User.find(:all, :conditions => {:category => 1})
            @admin_users =
                User
                .where(:category => 1)
            for user in @admin_users
              Notification.send_virus_info_report(@send_matter,
                                          @virus_attachments, @receivers, user).deliver
            end
          end
        end
    end
  end

  # flashなし版のファイル送信，SendMatter, Receiverへの書き込み
  def create_noflash
    if session[:send_matter_id]
      flash[:notice] = '既に送信完了しています。
       （ブラウザの「戻る」ボタンを押してからの送信は無効です）'
      redirect_to :action => 'result'
    else
      @total_file_size = 0
      params[:attachment].each do |key, value|
        if value[:file].size > (@params_app_env['FILE_SIZE_LIMIT'].to_i)*1024*1024
          flash[:notice] = 'ファイルサイズが制限を越えています。'
          redirect_to :action => 'result_ng' and return
        end
        @total_file_size += value[:file].size
        if @total_file_size >
            (@params_app_env['FILE_TOTAL_SIZE_LIMIT'].to_i)*1024*1024
          flash[:notice] = 'ファイルの合計サイズが制限を越えています。'
          redirect_to :action => 'result_ng' and return
        end
      end

      ActiveRecord::Base.transaction do
        @send_matter = SendMatter.new(post_params_send_matters)
        if session[:user_id].present? && current_user.present?
          @send_matter.user = current_user
        end
        @send_matter.url = generate_random_strings(rand(1000).to_s)
        @send_matter.status = 1
        if params[:mail_domain].present?
          @send_matter.mail_address += '@' + params[:mail_domain]
        end
        @send_matter.save!
        @attachments = Array.new
        @virus_attachments = Array.new
        @virus_down_attachments = Array.new
        @virus_error_attachments = Array.new
        params[:attachment].each do |key, value|
          @attachment = Attachment.new
          @attachment.send_matter = @send_matter
          @attachment.name = value[:file].original_filename
          @attachment.size = value[:file].size
          @attachment.save
          file_path = @params_app_env['FILE_DIR'] + "/#{@attachment.id}"
          File.open(file_path, "wb") do |f|
            f.binmode
            f.write(value[:file].read)
          end
          @attachment.file_save_pass = file_path
          if MIME::Types.type_for(value[:file].original_filename)[0]
            @attachment.content_type = MIME::Types.type_for(value[:file].original_filename)[0]
          else
            @attachment.content_type = ''
          end
          @attachment.relayid = 0
          @attachment.save
          if @params_app_env['VIRUS_CHECK'] == '1'
            # Virus Check
            @virus_check_result = get_virus_status(file_path)
            @attachment.virus_check = @virus_check_result
            @attachment.save!
            if(@virus_check_result != '0')
              if File.exist?(file_path)
                File.delete(file_path)
              end
            end
            unless @virus_check_result == '0'
              @virus_attachments.push @attachment
            end
          else
            @attachment.virus_check = '0'
            @attachment.save
          end
          @attachments.push @attachment
          unless @attachment.virus_check == '0' ||
             @attachment.virus_check == nil
            if @attachment.virus_check == t("virus_check_status.virus_check_down")
              @virus_down_attachments.push @attachment
            elsif @attachment.virus_check == t("virus_check_status.error")
              @virus_error_attachments.push @attachment
            end
          end
        end
        if @attachments.length == @virus_down_attachments.length
          flash[:notice] = 'ウィルスチェック機能が正常に動作していません。'
            redirect_to :action => 'send_ng2' and return
        elsif @attachments.length == @virus_error_attachments.length
          flash[:notice] = '送信失敗しました。もう一度送信してください。'
            redirect_to :action => 'send_ng' and return
        end

        params[:receiver].each do |key, value|
          @receiver = Receiver.new(receivers_params(value))
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
        if session[:user_id].present? && current_user.present?
          if current_user.moderate.present?
            @moderate = current_user.moderate
            @moderate_flag = 1
          else
            @moderate_flag = 0
          end
        else
          @moderate_value =
              AppEnv
              .where(["category = ?",
                      "`key` = ?"].join(" AND "),
                      0, 'MODERATE_DEFAULT').first
          if @moderate_value.present?
            @moderate =
                Moderate
                .where("id = ?",
                       @moderate_value.value).first
            if @moderate.present?
              @moderate_flag = 1
            else
              @moderate_flag = 0
            end
          else
            @moderate_flag = 0
          end
        end
        if @moderate_flag == 1
          @send_matter.moderate_flag = 1
          @send_matter.moderate_result = 0
          @send_moderate = SendModerate.new()
          @send_moderate.send_matter = @send_matter
          @send_moderate.moderate = @moderate
          @send_moderate.name = @moderate.name
          @send_moderate.type_flag = @moderate.type_flag
          @send_moderate.result = 0
          @send_moderate.save!
          for moderater in @moderate.moderaters
            send_moderater = SendModerater.new()
            send_moderater.moderater = moderater
            send_moderater.send_moderate = @send_moderate
            send_moderater.user = moderater.user
            send_moderater.user_name = moderater.user.name
            send_moderater.number = moderater.number
            send_moderater.send_flag = 0
            send_moderater.result = 0
            send_moderater.url =
                generate_random_strings(rand(10000).to_s)
            send_moderater.save!
          end
        else
          @send_matter.moderate_flag = 0
          @send_matter.moderate_result = 1
          @send_matter.sent_at = Time.now
        end
        @send_matter.save!
      end
      session[:send_matter_id] = @send_matter.id
      redirect_to :action => 'result'
      @receivers = @send_matter.receivers
      @attachments = @send_matter.attachments
      port = get_port()
      if @moderate_flag == 1
        if @send_moderate.type_flag == 0
          @send_moderater =
              SendModerater
              .where(["send_moderate_id = ?",
                      "number = 1"].join(" AND "),
                     @send_moderate.id).first
          url = port + "://" + @params_app_env['URL']
          Notification
              .send_matter_moderate_report(@send_matter, @send_moderater,
                  @send_moderater.user, url).deliver
          @send_moderater.send_flag = 1
          @send_moderater.save
        else
          @send_moderaters =
              SendModerater
              .where("send_moderate_id = ?",
                     @send_moderate.id)
          for send_moderater in @send_moderaters
            url = port + "://" + @params_app_env['URL']
            Notification
                .send_matter_moderate_report(@send_matter, send_moderater,
                    send_moderater.user, url).deliver
            send_moderater.send_flag = 1
            send_moderater.save
          end
        end
        url = port + "://" + @params_app_env['URL']
        Notification
            .send_matter_moderate_copied_report(@send_matter, @send_moderate,
                url).deliver
      else
        flash[:notice] = 'ファイル送信を完了しました。'

        if @attachments.select{ |attachment|
            (attachment.virus_check == '0' ||
             attachment.virus_check == nil) }.size > 0
          @receivers.each do |receiver|
            full_url_dl = port + "://" + @params_app_env['URL'] +
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

        url_dl = port + "://" + @params_app_env['URL']
        Notification.send_result_report(@send_matter,
                                        @receivers, @attachments,
                                        url_dl).deliver
      end
      if @virus_attachments.length > 0
        if @params_app_env['VIRUS_CHECK_NOTICE'] == '1'
#          @admin_users = User.find(:all, :conditions => {:category => 1})
          @admin_users =
              User
              .where(:category => 1)
          for user in @admin_users
            Notification.send_virus_info_report(@send_matter,
                                        @virus_attachments, @receivers, user).deliver
          end
        end
      end
    end
  rescue => e
    logger.error "#{e.class} (#{e.message}):\n#{Rails.backtrace_cleaner.clean(e.backtrace).join("\n").indent(1)}"
    flash[:notice] = '送信失敗しました。もう一度送信してください。'
    redirect_to :action => 'send_ng' and return
  end

  def result
    session[:site_category] = nil
    if params[:id]
#      @send_matter = SendMatter.find(:first, :conditions => { :url => params['id'] })
      @send_matter =
          SendMatter
          .where(:url => params['id'])
          .first
      session[:send_matter_id] = @send_matter.id
    else
      @send_matter = SendMatter.find(session[:send_matter_id])
    end

    if @send_matter.sent_at.present?
      if (Time.now - (Time.parse(@send_matter.sent_at.to_s) +
                      @send_matter.file_life_period)) > 0
        flash[:notice] = "ファイルの保管期限を過ぎましたので削除されました。"
        redirect_to :action => "result_ng"
      end
    end
    @port = get_port()
    @port = @port + "://"
    @receivers = @send_matter.receivers
    @attachments = @send_matter.attachments
    if @send_matter.moderate_flag == 1
      @send_moderate = @send_matter.send_moderate
      @send_moderaters = @send_moderate.send_moderaters
    end
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "不正なアクセスです。
                     （アクセスの集中，ブラウザの操作上の問題が考えられます。）"
    redirect_to :action => "result_ng"
  end

  def login
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "不正なアクセスです。
                     （アクセスの集中，ブラウザの操作上の問題が考えられます。）"
    redirect_to :action => "result_ng"
  end

  def auth
    @authorize_use_flg = 0
    @authorization_flg = 0
    Dir.glob("vendor/engines/*/").each do |path|
      engine = path.split("\/")[2]
      if eval("ApplicationController.method_defined?(:#{engine}_authorization_check)")
        puts 'auth01'
        local_authorization = eval("#{engine}_authorization_check")
        if @authorize_use_flg == 0 && local_authorization[0] == 1
          @authorize_use_flg = local_authorization[0]
        end
        if @authorization_flg == 0 && local_authorization[1] > 0
          @authorization_flg = local_authorization[1]
        end
      end
    end

    if @authorize_use_flg == 0
      user =
          User
          .where("login = ?",
                 params[:login]).first
      if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        @authorization_flg = 1
      else
        flash[:notice] = "ユーザあるいはパスワードが違います"
        @authorization_flg = 0
      end
    end
    if @authorization_flg == 1
      redirect_to :action => 'result', :id => session[:url_id]
      flash[:notice] = "ログインしました。"
    elsif @authorization_flg == 2
      render :plain => "有効期限が過ぎています。"
    elsif @authorization_flg == 0
      flash[:notice] = "ユーザあるいはパスワードが違います"
      redirect_to :action => 'login'
    else
      flash[:notice] = "ユーザあるいはパスワードが違います"
      redirect_to :action => 'login'
    end
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
    if @attachment.present? && @attachment.send_matter_id == session[:send_matter_id]
      filename = @params_app_env['FILE_DIR'] + "/" + @attachment.id.to_s
      if File.exist?(filename)
        File.delete(filename)
      end
      @attachment.destroy
      @receivers.each do |receiver|
        Notification.file_delete_report(@send_matter,
                                        receiver,
                                        @attachment).deliver
      end
      port = get_port()
      url = port + "://" + @params_app_env['URL']

      Notification.file_delete_result_report(@send_matter,
                                             @receivers,
                                             @attachment, url).deliver
      flash[:notice] = "#{@attachment.name} を削除しました。"
      redirect_to(:action => "result")
    else
      flash[:notice] = "選択されたファイルはすでに削除されています。"
      redirect_to(:action => "result")
    end
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "不正なアクセスです。
                     （アクセスの集中，ブラウザの操作上の問題が考えられます。）"
    redirect_to :action => "result_ng"
  end

  private

  def result_id_check
    if params[:id].present?
      session[:url_id] = params[:id]
#    else
#      flash[:notice] = "不正なアクセスです。
#                       （アクセスの集中，ブラウザの操作上の問題が考えられます。）"
#      redirect_to :action => "result_ng"
    end
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "不正なアクセスです。
                     （アクセスの集中，ブラウザの操作上の問題が考えられます。）"
    redirect_to :action => "result_ng"
  end

  def result_authorize
    session[:autorize] = 'yes'
    @local_ips =
        AppEnv
        .where("app_envs.key = 'LOCAL_IPS'")

    @authorize_use_flg = 0
    @authorization_flg = 0
    Dir.glob("vendor/engines/*/").each do |path|
      engine = path.split("\/")[2]
      if eval("ApplicationController.method_defined?(:#{engine}_authorize)")
        local_authorization = eval("#{engine}_authorize")
        if local_authorization[0] == 1
          @authorize_use_flg = local_authorization[0]
        end
        if @authorization_flg == 0 && local_authorization[1] > 0
          @authorization_flg = local_authorization[1]
        end
      end
    end
    if @authorize_use_flg == 1
      if @authorization_flg == 1
        session[:user_category] = 2
      else
        redirect_to :action => "login"
        cookies.delete :auth_token
      end
    else
      if @local_ips.select{ |local_ip|
              IPAddr.new(local_ip.value).include?(@access_ip) }.size > 0
        session[:user_category] = 3
      else
        if session[:user_id].present?
          session[:user_category] = 2
        else
          redirect_to :action => "login"
          cookies.delete :auth_token
        end
      end
    end
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "不正なアクセスです。
                     （アクセスの集中，ブラウザの操作上の問題が考えられます。）"
    redirect_to :action => "result_ng"
  end

  def post_params_send_matters
    params.require(:send_matter).permit(
      :relayid, :name, :mail_address, :receive_password, :password_notice, :download_check, :file_life_period, :message
    )
  end

  def receivers_params(post_params)
    post_params.permit(
      :name, :mail_address
    )
  end

  def attachments_params(post_params)
    post_params.permit(
      :name, :mail_address
    )
  end
end
