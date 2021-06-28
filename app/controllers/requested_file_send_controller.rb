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
  before_action :load_env

  def blank
  end

  # 認証画面(メールのリンク先)
  def login
    @url_code = params[:id]
#    @requested_matter = RequestedMatter.find(:first,
#                                        :conditions => { :url => @url_code })
    @requested_matter =
        RequestedMatter
        .where({ :url => @url_code })
        .first
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
#    @requested_matter = RequestedMatter.find(:first,
#            :conditions => {
#              :id => session[:"#{@url_code}"]['requested_matter_id'] })
    @requested_matter =
        RequestedMatter
        .where({ :id => session[:"#{@url_code}"]['requested_matter_id'] })
        .first

    if @requested_matter.send_password == params[:login]['send_password']
      if @requested_matter.request_matter.sent_at.present?
        if (Time.now - (Time.parse(@requested_matter.request_matter.sent_at.to_s) +
                @params_app_env['REQUEST_PERIOD'].to_i)) > 0
          @request_send_flag = false
        else
          @request_send_flag = true
        end
      elsif @send_matter.moderate_flag == nil
        if (Time.now - (Time.parse(@requested_matter.request_matter.created_at.to_s) +
                @params_app_env['REQUEST_PERIOD'].to_i)) > 0
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
  def index
    @url_code = session[:request_send_url_code]
    if session[:"#{@url_code}"]['auth'] == 'yes'
#      @file_life_period_vals = AppEnv.find(:all,
#              :conditions => { :key => "FILE_LIFE_PERIOD" },
#              :order => 'id ASC' )
      @file_life_period_vals =
          AppEnv
          .where({:key => "FILE_LIFE_PERIOD"})
          .order('id ASC')

#      @requested_matter = RequestedMatter.find(:first,
#              :conditions => {
#                :id => session[:"#{@url_code}"]['requested_matter_id'] })
      @requested_matter =
          RequestedMatter
          .where({:id => session[:"#{@url_code}"]['requested_matter_id']})
          .first

      if @requested_matter.file_up_date
        flash[:notice] = "すでに送信していただいてます"
        redirect_to :action => 'blank'
      else
        password_length = @params_app_env['PW_LENGTH_MIN'].to_i +
          (@params_app_env['PW_LENGTH_MAX'].to_i - @params_app_env['PW_LENGTH_MIN'].to_i) / 2
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

  def index_flash
    index()
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
#      @file_life_period_vals = AppEnv.find(:all,
#              :conditions => { :key => "FILE_LIFE_PERIOD" },
#              :order => 'id ASC' )
      @file_life_period_vals =
          AppEnv
          .where({:key => "FILE_LIFE_PERIOD"})
          .order('id ASC')

#      @requested_matter = RequestedMatter.find(:first,
#              :conditions => {
#              :id => session[:"#{@url_code}"]['requested_matter_id'] })
      @requested_matter =
          RequestedMatter
          .where(:id => session[:"#{@url_code}"]['requested_matter_id'])
          .first

      if @requested_matter.file_up_date
        flash[:notice] = "すでに送信していただいてます"
        redirect_to :action => 'blank'
      else
        password_length = @params_app_env['PW_LENGTH_MIN'].to_i +
          (@params_app_env['PW_LENGTH_MAX'].to_i - @params_app_env['PW_LENGTH_MIN'].to_i) / 2
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

  # アップロード処理
  def upload5
    @requested_matter =
        RequestedMatter
        .where("id = ?", params[:requsted_matter_id])
        .first

    session[:request_send_url_code] = @requested_matter.url

    unless @requested_matter.file_up_date
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

        tmp_path = @params_app_env['FILE_DIR'] if file_data
        raise "upload failure" unless file_data

        @requested_attachment = RequestedAttachment.new
        @requested_attachment.name = file_name
        @requested_attachment.size = file_data.size
        @requested_attachment.requested_matter_id = @requested_matter.id
        @requested_attachment.download_flg = 0
        @requested_attachment.save

        FileUtils.mkdir_p(tmp_path) unless FileTest.exist?(tmp_path)
        file_path = "#{tmp_path}/r#{@requested_attachment.id}"
        File.open(file_path, "w") do |f|
          f.binmode
          f.write(file_data)
        end

        if file.content_type.blank?
          if MIME::Types.type_for(params[:Filedata].original_filename)[0].content_type
            @requested_attachment.content_type = MIME::Types.type_for(params[:Filedata].original_filename)[0].content_type
          else
            @requested_attachment.content_type = ''
          end
        else
          @requested_attachment.content_type = file.content_type
        end
        @requested_attachment.file_save_pass = file_path
        @requested_attachment.relayid = params[:relay_id]
        @requested_attachment.save
        if @params_app_env['VIRUS_CHECK'] == '1'
          # Virus Check
          @virus_check_result = get_virus_status(file_path)
          @requested_attachment.virus_check = @virus_check_result
          @requested_attachment.save
          if(@virus_check_result != '0')
            if File.exist?(file_path)
              File.delete(file_path)
            end
          end
        else
          @requested_attachment.virus_check = '0'
          @requested_attachment.save
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
    else
      if params[:myfile].present?
        file = params[:myfile]
        file_name = file.original_filename
      else
        file_name = 'NULL'
      end
      render :json => { :error => file_name, :id => "00000" }
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
      render :plain => "success!"

      ActiveRecord::Base.transaction do
        @requested_attachment = RequestedAttachment.new()
        @requested_attachment.name = params[:Filename]
        @requested_attachment.size = params[:Filedata].size
        @requested_attachment.requested_matter_id = @requested_matter.id
        @requested_attachment.download_flg = 0
        @requested_attachment.save!
        @file = params[:Filedata]
        file_path = "#{@params_app_env['FILE_DIR']}/r#{@requested_attachment.id}"
        if @file
          File.open(file_path, "w") do |f|
            f.binmode
            f.write(@file.read)
          end
        end
        if MIME::Types.type_for(params[:Filedata].original_filename)[0].content_type
          @requested_attachment.content_type = MIME::Types.type_for(params[:Filedata].original_filename)[0].content_type
        else
          @requested_attachment.content_type = ''
        end
        @requested_attachment.file_save_pass = file_path
        @requested_attachment.save!
        if @params_app_env['VIRUS_CHECK'] == '1'
          # Virus Check
          @virus_check_result = get_virus_status(file_path)
          @requested_attachment.virus_check = @virus_check_result
          @requested_attachment.save!
          if(@virus_check_result != '0')
            if File.exist?(file_path)
              File.delete(file_path)
            end
          end
        else
          @requested_attachment.virus_check = '0'
          @requested_attachment.save
        end
      end
    end
  end

  # 依頼送信に関連するカラムの作成
  def create
#    @requested_matter = RequestedMatter.find(:first,
#            :conditions => { :id => params[:requested_matter_id] })
    @requested_matter =
        RequestedMatter
        .where(:id => params[:requested_matter_id])
        .first

    @url_code =params[:requested_matter_url]

    if session[:"#{@url_code}"]['requested_matter_id'] ==
            @requested_matter.id
      session[:request_send_url_code] = @requested_matter.url

      if @requested_matter.file_up_date
        flash[:notice] = "すでに送信しております"
        redirect_to :action => 'blank'
      else
#        @requested_attachments = RequestedAttachment.find(:all,
#                :conditions => {
#                  :requested_matter_id =>
#                    session[:"#{@url_code}"]['requested_matter_id'] })
        @requested_attachments =
            RequestedAttachment.where(:requested_matter_id =>
                    session[:"#{@url_code}"]['requested_matter_id'])

        if @requested_attachments.length < 1
          flash[:notice] = "送信失敗しました。もう一度送信してください。"
          redirect_to :action => 'send_ng'
        else
          ActiveRecord::Base.transaction do
            @virus_attachments = Array.new
            @requested_attachments.each do |attachment|
              unless attachment.virus_check == '0' ||
                      attachment.virus_check == nil
                @virus_attachments.push attachment
              end
            end
            @requested_matter.update_attributes(requested_matters_params(params[:requested_matter]))
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
          full_url_dl = port + "://" + @params_app_env['URL'] +
                  "/requested_file_receive/login/" +
                  "#{@requested_matter.url}"
          full_url_check = port + "://" + @params_app_env['URL'] +
                  "/requested_file_send/result/" +
                  "#{@requested_matter.url_operation}"

          if @requested_attachments.select{ |requested_attachment|
                  (requested_attachment.virus_check == '0' ||
                   requested_attachment.virus_check == nil) }.size > 0
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
            if @params_app_env['VIRUS_CHECK_NOTICE'] == '1'
#              @admin_users =
#                  User.find(:all, :conditions =>
#                  {:category => 1})
              @admin_users =
                  User.where({:category => 1})
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
                  full_url_check, @params_app_env['PASSWORD_AUTOMATION'].to_i).deliver
        end
      end
    else
      flash[:notice] = "不正なアクセスです"
      redirect_to :action => 'blank'
    end
  end

  def create_noflash
#    @requested_matter = RequestedMatter.find(:first,
#            :conditions => { :id => params[:requested_matter_id] })
    @requested_matter =
        RequestedMatter
        .where({:id => params[:requested_matter_id]})
        .first

    @url_code =params[:requested_matter_url]

    if session[:"#{@url_code}"]['requested_matter_id'] ==
            @requested_matter.id
      session[:request_send_url_code] = @requested_matter.url

      if @requested_matter.file_up_date
        flash[:notice] = "すでに送信しております"
        redirect_to :action => 'blank'
      else
#        @requested_attachments = RequestedAttachment.find(:all,
#                :conditions => {
#                  :requested_matter_id =>
#                    session[:"#{@url_code}"]['requested_matter_id'] })
        @requested_attachments =
            RequestedAttachment
            .where(:requested_matter_id =>
                   session[:"#{@url_code}"]['requested_matter_id'])
            .first
          @total_file_size = 0

          params[:attachment].each do |key, value|
            if value[:file].size >
                    (@params_app_env['FILE_SIZE_LIMIT'].to_i)*1024*1024
              flash[:notice] = 'ファイルサイズが制限を越えています。'
              redirect_to :action => 'blank' and return
            end
            @total_file_size += value[:file].size
            if @total_file_size >
                    (@params_app_env['FILE_TOTAL_SIZE_LIMIT'].to_i)*1024*1024
              flash[:notice] = 'ファイルの合計サイズが制限を越えています。'
              redirect_to :action => 'blank' and return
            end
          end

          ActiveRecord::Base.transaction do
            @virus_attachments = Array.new

            @requested_matter.update_attributes(requested_matters_params(params[:requested_matter]))
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

              file_path = "#{@params_app_env['FILE_DIR']}/r#{@requested_attachment.id}"
              File.open(file_path, "w") do |f|
                f.binmode
                f.write(value[:file].read)
              end
              if (MIME::Types.type_for(value[:file].original_filename)[0])
                @requested_attachment.content_type = MIME::Types.
                        type_for(value[:file].original_filename)[0].content_type
              else
                @requested_attachment.content_type = ''
              end
              @requested_attachment.file_save_pass = file_path
              @requested_attachment.save!
              if @params_app_env['VIRUS_CHECK'] == '1'
                # Virus Check
                @virus_check_result = get_virus_status(file_path)
                @requested_attachment.virus_check = @virus_check_result
                @requested_attachment.save!
                unless @virus_check_result == '0'
                  if File.exist?(file_path)
                    File.delete(file_path)
                  end
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
          full_url_dl = port + "://" + @params_app_env['URL'] +
                  "/requested_file_receive/login/" +
                  "#{@requested_matter.url}"
          full_url_check = port + "://" + @params_app_env['URL'] +
                  "/requested_file_send/result/" +
                  "#{@requested_matter.url_operation}"

          if @requested_attachments.select{ |requested_attachment|
                  (requested_attachment.virus_check == '0' ||
                   requested_attachment.virus_check == nil) }.size > 0
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
            if @params_app_env['VIRUS_CHECK_NOTICE'] == '1'
#              @admin_users =
#                  User.find(:all, :conditions =>
#                  {:category => 1})
              @admin_users =
                  User.where({:category => 1})
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
                  full_url_check, @params_app_env['PASSWORD_AUTOMATION'].to_i).deliver
      end
    else
      flash[:notice] = "不正なアクセスです"
      redirect_to :action => 'blank'
    end
  end

  # 依頼送信結果
  def result
    session[:requested_matter_id] = nil
    if params[:id].present?
      @requested_matter =
        RequestedMatter
        .where([["url_operation = ?",
                 ].join(" AND "),
                 params[:id],
                ])
        .first
      if @requested_matter.present? &&
          session[:"#{@requested_matter.url}"].present? &&
          session[:"#{@requested_matter.url}"]['auth'] == 'yes'
        @url_code = @requested_matter.url
        session[:requested_matter_id] = @requested_matter.id
      end
    end

    if session[:requested_matter_id]
      @requested_attachments =
          RequestedAttachment
          .where({:requested_matter_id => session[:requested_matter_id]})
    else
      if params[:id]
        redirect_to(:action => "result_login", :id => params[:id])
      else
        flash[:notice] = "不正なアクセスです"
        redirect_to(:action => "blank")
      end
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
      if @attachment.present?
        if @attachment.requested_matter_id == session[:requested_matter_id]
          filename = @params_app_env['FILE_DIR'] + "/r" + @attachment.id.to_s
          if File.exist?(filename)
            File.delete(filename)
          end
          @attachment.destroy

          port = get_port()
          url = port + "://" + @params_app_env['URL']
          Notification.requested_file_delete_report(
                  @requested_matter, @attachment).deliver

          Notification.requested_file_delete_copied_report(
                  @requested_matter, @attachment, url).deliver

          flash[:notice] = "#{@attachment.name} を削除しました。"
          redirect_to(:action => "result", :id => @requested_matter.url_operation)
        else
          flash[:notice] = "不正なアクセスです。"
          redirect_to(:action => "blank")
        end
      else
        flash[:notice] = "#{@attachment.name} はすでに削除されています。"
        redirect_to(:action => "result", :id => @requested_matter.url_operation)
      end
    else
      flash[:notice] = "不正なアクセスです。"
      redirect_to(:action => "blank")
    end
  end

  # 認証画面(メールのリンク先)
  def result_login
    @url_operation = params[:id]
    @requested_matter =
        RequestedMatter
        .where({ :url_operation => @url_operation })
        .first
    pass_port = 'pass'
    if params[:id].present? && @requested_matter.present?
      @url_code = @requested_matter.url
      if @requested_matter.file_up_date
        session[:request_send_url_code] = @url_code
        if session[:"#{@url_code}"]
          if session[:"#{@url_code}"]['auth']
            pass_port = ''
            session[:site_category] = session[:"#{@url_code}"]['site_category']
            redirect_to :action => 'result'
          end
        end

        if pass_port == 'pass'
          session[:"#{@url_code}"] ||= Hash.new
          session[:"#{@url_code}"]['auth'] = nil
          session[:"#{@url_code}"]['site_category'] = "requested_file_send"
          session[:"#{@url_code}"]['requested_matter_id'] = @requested_matter.id
          session[:site_category] = session[:"#{@url_code}"]['site_category']
          unless flash[:notice]
            flash[:notice] = "ファイル送信時のセッションが切れているため、再度ログインしてください。"
          end
        end
      else
        flash[:notice] = "送信が完了しておりません。"
        redirect_to :action => 'blank'
      end
    else
      flash[:notice] = "不正なアクセスです。"
      redirect_to :action => 'blank'
    end
  end

  # 認証チェック
  def result_auth
    @url_code = session[:request_send_url_code]
    @requested_matter =
        RequestedMatter
        .where({ :id => session[:"#{@url_code}"]['requested_matter_id'] })
        .first
    if @requested_matter.send_password == params[:login]['send_password']
      @request_send_flag = true
      if @request_send_flag == true
        session[:"#{@url_code}"]['auth'] = "yes"
        flash[:notice] = "ログインしました。"
        redirect_to :action => 'result', :id => @requested_matter.url_operation
      else
        flash[:notice] = "ファイルの送信依頼期限を過ぎています。"
        redirect_to :action => 'blank'
      end
    else
      flash[:notice] = "パスワードが違います。"
      redirect_to :action => 'result_login', :params =>
              { :id => @requested_matter.url_operation }
    end
  end

  def send_ng
  end

  private

  def post_params_request_matters
    params.require(:request_matter).permit(
      :name, :mail_address, :message
    )
  end

  def requested_matters_params(post_params)
    post_params.permit(
      :receive_password, :password_notice, :download_check, :file_life_period, :message
    )
  end
end
