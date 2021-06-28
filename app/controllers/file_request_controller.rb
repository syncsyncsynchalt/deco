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
class FileRequestController < ApplicationController
  protect_from_forgery :except => [:upload]
  before_action :authorize, :except => [:result, :login, :auth, :result_ng]
  before_action :result_id_check, :only => [:result]
  before_action :result_authorize, :only => [:result]
  before_action :load_env

  # 入力フォーム
  def index
    session[:site_category] = nil
    @request_matter = RequestMatter.new
    @request_matter.class_eval { attr_accessor :mail_domain }
    @requested_matter = RequestedMatter.new
    @requested_attachement = RequestedAttachment.new

    @login_user_exist_flg = 0
    Dir.glob("vendor/engines/*/").each do |path|
      engine = path.split("\/")[2]
      if eval("ApplicationController.method_defined?(:#{engine}_get_user_info)")
        if @login_user_exist_flg == 0
          local_user_info = eval("#{engine}_get_user_info")
          if local_user_info[0] == 1
            @login_user_exist_flg = local_user_info[0]
            @request_matter.name = local_user_info[1]
            @request_matter.mail_address = local_user_info[2]
          end
        end
      end
    end
    if @login_user_exist_flg == 0
      if session[:user_id].present? && current_user.present?
        if current_user.from_organization_add.present?
          @request_matter.name = "#{current_user.from_organization_add}　#{current_user.name}"
        else
          @request_matter.name = "#{current_user.name}"
        end
        if @local_ips.select{ |local_ip| IPAddr.new(local_ip.value).include?(@access_ip) }.size > 0
          count = 0
          for key_word in current_user.email.split(/\@/)
            if count == 0
              @request_matter.mail_address = key_word
            else
              @request_matter.mail_domain = key_word
            end
            count += 1
          end
        else
          @request_matter.mail_address = current_user.email
        end
      end
    end
    respond_to do |format|
      format.html
      format.xml { render :xml => @request_file }
    end
  end

  # 依頼内容作成
  def create
    recipients = Hash.new

#    ActiveRecord::Base.transaction do
#      @request_matter = RequestMatter.new(post_params_request_matters)
#      @request_matter.url = generate_random_strings(@request_matter.name)
#      if params[:mail_domain].present?
#        @request_matter.mail_address += '@' + params[:mail_domain]
#      end
#      if session[:user_id].present? && current_user.present?
#        @request_matter.user = current_user
#      end
#      @request_matter.save!
#      params[:requested_matter].each{ |key, value|
#        @requested_matter = RequestedMatter.new(requested_matters_params(value))
#        @requested_matter.request_matter = @request_matter
#        @requested_matter.url = generate_random_strings(@requested_matter.name)
#        @requested_matter.send_password =
#            generate_random_string_values(@requested_matter.mail_address).slice(1,8)
#        @requested_matter.save!
#
#        recipients[@requested_matter.id] = [ @requested_matter.mail_address,
#                                             @requested_matter.name,
#                                             @requested_matter.url,
#                                             @requested_matter.send_password ]
#      }
#      @moderate_flag = get_moderate_flag()
#      if @moderate_flag == 1
#        @request_matter.moderate_flag = 1
#        @request_matter.moderate_result = 0
#        @request_moderate = RequestModerate.new()
#        @request_moderate.request_matter = @request_matter
#        @request_moderate.moderate = @moderate
#        @request_moderate.name = @moderate.name
#        @request_moderate.type_flag = @moderate.type_flag
#        @request_moderate.result = 0
#        @request_moderate.save!
#        for moderater in @moderate.moderaters
#          request_moderater = RequestModerater.new()
#          request_moderater.moderater = moderater
#          request_moderater.request_moderate = @request_moderate
#          request_moderater.user = moderater.user
#          request_moderater.user_name = moderater.user.name
#          request_moderater.number = moderater.number
#          request_moderater.send_flag = 0
#          request_moderater.result = 0
#          request_moderater.url =
#              generate_random_strings(rand(10000).to_s)
#          request_moderater.save!
#        end
#      else
#        @request_matter.moderate_flag = 0
#        @request_matter.moderate_result = 1
#        @request_matter.sent_at = Time.now
#      end
#
#      unless @request_matter.save!
#        render :action => 'index'
#      end
#    end

    begin
      ActiveRecord::Base.transaction do
        @request_matter = RequestMatter.new(post_params_request_matters)
        @request_matter.url = generate_random_strings(@request_matter.name)
        if params[:mail_domain].present?
          @request_matter.mail_address += '@' + params[:mail_domain]
        end
        if session[:user_id].present? && current_user.present?
          @request_matter.user = current_user
        end
        @request_matter.save!
        params[:requested_matter].each{ |key, value|
          @requested_matter = RequestedMatter.new(requested_matters_params(value))
          @requested_matter.request_matter = @request_matter
          @requested_matter.url = generate_random_strings(@requested_matter.name)
          @requested_matter.send_password =
              generate_random_string_values(@requested_matter.mail_address).slice(1,8)
          @requested_matter.save!

          recipients[@requested_matter.id] = [ @requested_matter.mail_address,
                                               @requested_matter.name,
                                               @requested_matter.url,
                                               @requested_matter.send_password ]
        }
        @moderate_flag = get_moderate_flag()
        if @moderate_flag == 1
          @request_matter.moderate_flag = 1
          @request_matter.moderate_result = 0
          @request_moderate = RequestModerate.new()
          @request_moderate.request_matter = @request_matter
          @request_moderate.moderate = @moderate
          @request_moderate.name = @moderate.name
          @request_moderate.type_flag = @moderate.type_flag
          @request_moderate.result = 0
          @request_moderate.save!
          for moderater in @moderate.moderaters
            request_moderater = RequestModerater.new()
            request_moderater.moderater = moderater
            request_moderater.request_moderate = @request_moderate
            request_moderater.user = moderater.user
            request_moderater.user_name = moderater.user.name
            request_moderater.number = moderater.number
            request_moderater.send_flag = 0
            request_moderater.result = 0
            request_moderater.url =
                generate_random_strings(rand(10000).to_s)
            request_moderater.save!
          end
        else
          @request_matter.moderate_flag = 0
          @request_matter.moderate_result = 1
          @request_matter.sent_at = Time.now
        end

        @request_matter.save!
      end
    rescue => e
      logger.error "#{e.class} (#{e.message}):\n#{Rails.backtrace_cleaner.clean(e.backtrace).join("\n").indent(1)}"
      flash[:notice] = '依頼失敗しました。もう一度依頼してください。'
      redirect_to :action => 'result_ng' and return
    end
    
    
    session[:request_matter_id] = @request_matter.id

    flash[:notice] = 'ファイル依頼を完了しました。'
    redirect_to :action => 'result'

    port = get_port()
    if @moderate_flag == 1
      if @request_moderate.type_flag == 0
        @request_moderater =
            RequestModerater
            .where(["request_moderate_id = ?",
                    "number = 1"].join(" AND "),
                   @request_moderate.id).first
          url = port + "://" + @params_app_env['URL']
          Notification
              .request_matter_moderate_report(@request_matter, @request_moderater,
                  @request_moderater.user, url).deliver
        @request_moderater.send_flag = 1
        @request_moderater.save
      else
        @request_moderaters =
            RequestModerater
            .where("request_moderate_id = ?",
                   @request_moderate.id)
        for request_moderater in @request_moderaters
          url = port + "://" + @params_app_env['URL']
          Notification
              .request_matter_moderate_report(@request_matter, request_moderater,
                  request_moderater.user, url).deliver
          request_moderater.send_flag = 1
          request_moderater.save
        end
      end
      Notification
          .request_matter_moderate_copied_report(@request_matter, @request_moderate,
              url).deliver
    else
      recipients.each{ |key, value|
        full_url = port + "://" + @params_app_env['URL'] +
            "/requested_file_send/login/" + value[2]

        Notification.request_report(@request_matter,
                                    value[1], value[0],
                                    full_url, value[3],
                                    @params_app_env['REQUEST_PERIOD'].to_i).deliver
        Notification.request_password_report(@request_matter,
                                    value[1], value[0],
                                    full_url, value[3],
                                    @params_app_env['REQUEST_PERIOD'].to_i).deliver
      }

      req_url = port + "://" + @params_app_env['URL']
      @requested_matters = @request_matter.requested_matters
      Notification.request_copied_report(@request_matter,
                                         @requested_matters, req_url,
                                         @params_app_env['REQUEST_PERIOD'].to_i).deliver
    end
  end

  def result
    if params[:id].present?
#      @request_matter = RequestMatter.find(:first, :conditions =>
#                                     { :url => params[:id] })
      @request_matter =
          RequestMatter
          .where(:url => params[:id])
          .first
      session[:request_matter_id] = @request_matter.id
    else
      @request_matter = RequestMatter.find(session[:request_matter_id])
    end
#    @requested_matters =
#        RequestedMatter.find_all_by_request_matter_id(session[:request_matter_id])
    @requested_matters =
        RequestedMatter
        .where(request_matter_id: session[:request_matter_id])
    if @request_matter.moderate_flag == 1
      @request_moderate = @request_matter.request_moderate
      @request_moderaters = @request_moderate.request_moderaters
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
    render :action => 'message'
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

  def post_params_request_matters
    params.require(:request_matter).permit(
      :name, :mail_address, :message
    )
  end

  def requested_matters_params(post_params)
    post_params.permit(
      :name, :mail_address
    )
  end
end
