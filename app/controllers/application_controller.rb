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
class ApplicationController < ActionController::Base
  #ActionController::Baseのソースを読むとここで様々なmoduleをincludeしている
  module DataStreamPatch
    def send_file_headers!(options)
      super(options)
      match = /(.+); filename="(.+)"/.match(headers['Content-Disposition'])
      if match.present?
        encoded = URI.encode_www_form_component(match[2]).gsub("+", "%20")
        headers['Content-Disposition'] = "#{match[1]}; filename*=UTF-8''#{encoded}" unless encoded == match[2]
      end
    end
  end

  module ActionController
    module DataStreaming
      prepend DataStreamPatch
    end
  end

  #moduleの動作を書き換えた上で再度includeする必要がある。
  include ActionController::DataStreaming

#  self.allow_forgery_protection = false
  self.allow_forgery_protection = true
#  include AuthenticatedSystem
  include Nmt
  helper_method :current_user
  helper :all
  before_action :check_access_ip

  $content_item_category = Array.new

#  protect_from_forgery

  protect_from_forgery with: :exception

  def check_access_ip
#=begin
    access_ip_lists = Array.new
    remote_access_ip_lists = Array.new
    local_access_ip_lists = Array.new
    if request.env['REMOTE_ADDR'].present?
#      puts "REMOTE_ADDR = #{request.env['REMOTE_ADDR']}"
      for access_ip in request.env['REMOTE_ADDR'].split(',')
        if access_ip =~ /^\d+\.\d+\.\d+\.\d+|\d+\.\d+\.\d+\.\d+\/\d+$/
          access_ip_lists.unshift(access_ip)
          @access_ip = access_ip
        end
      end
    end
    if request.env['HTTP_X_FORWARDED_FOR'].present?
#      puts "HTTP_X_FORWARDED_FOR = #{request.env['HTTP_X_FORWARDED_FOR']}"
      for access_ip in request.env['HTTP_X_FORWARDED_FOR'].split(',')
        if access_ip =~ /^\d+\.\d+\.\d+\.\d+|\d+\.\d+\.\d+\.\d+\/\d+$/
          access_ip_lists.unshift(access_ip)
          @access_ip = access_ip
        end
      end
    end
    for access_ip in access_ip_lists
      if IPAddr.new("10.0.0.0/8").include?(access_ip) ||
          IPAddr.new("172.16.0.0/16").include?(access_ip) ||
          IPAddr.new("192.168.0.0/16").include?(access_ip)
        local_access_ip_lists << access_ip
#        puts "local_access_ip = #{access_ip}"
      else
        remote_access_ip_lists << access_ip
#        puts "remote_access_ip = #{access_ip}"
      end
    end
    if remote_access_ip_lists.size > 0
      @access_ip = remote_access_ip_lists[0]
    else
      if local_access_ip_lists.size > 0
        @access_ip = local_access_ip_lists[0]
      end
    end
#=end
=begin
    @access_ip = request.env['HTTP_X_FORWARDED_FOR']
    if @access_ip
      @access_ip = @access_ip.split(',')[0] if @access_ip.include?(',')
      unless @access_ip =~ /^\d+\.\d+\.\d+\.\d+|\d+\.\d+\.\d+\.\d+\/\d+$/
        @access_ip = request.env['REMOTE_ADDR']
      end
    else
      @access_ip = request.env['REMOTE_ADDR']
    end
=end
#    @access_ip = request.env['REMOTE_ADDR']
  end

  # ログインチェック
  def logged_in
    if session[:user_id].blank?
      redirect_to new_session_url
    end
  end

  # ログインユーザ取得
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # check IP and login user
  def authorize
    begin
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
          redirect_to :controller => "sessions", :action => "new"
          cookies.delete :auth_token
        end
      else
        if @local_ips.select{ |local_ip|
                IPAddr.new(local_ip.value).include?(@access_ip) }.size > 0
          session[:user_category] = 3
        else
          if session[:user_id].present?
            if User.find_by(id: session[:user_id]).present?
              session[:user_category] = 2
            else
              redirect_to :controller => "sessions", :action => "new"
              cookies.delete :auth_token
            end
          else
            redirect_to :controller => "sessions", :action => "new"
          end
        end
      end
    rescue EOFError, Errno::ECONNRESET
      retry
    end
  end

  # check login user for administrator
  def administrator_authorize
    users =
        User
        .where("category = 1")

    if users.length > 0
      if session[:user_id].present?
        user =
            User
            .where("category = 1 AND " +
                   "login = ?",
                   current_user.login)
        if user.length == 0
          cookies.delete :auth_token
          reset_session
          redirect_to :controller => "sessions",
                  :action => "new_for_administrator"
        end
      else
        redirect_to :controller => "sessions",
                :action => "new_for_administrator"
      end
    else
      if session[:user_id].present?
        cookies.delete :auth_token
        reset_session
      end
    end
  end

  # check IP in administrator
  def check_ip_for_administrator
    @local_ips =
        AppEnv
        .where("app_envs.key = 'PERMIT_OPERATION_IPS'")

    unless @local_ips.size == 0
      unless @local_ips.select{ |local_ip|
              IPAddr.new(local_ip.value).include?(@access_ip) }.size > 0
        render :plain => "このIPアドレス（#{@access_ip}）は許可されていません。"
      end
    end
  end

  # 環境変数を読み込む
  def load_env
    @local_domains = ''
    @local_domain_list = Array.new
    @local_ips = Array.new
    @file_life_periods = Array.new
    @params_app_env = Hash.new
#    $local_domains = ""
#    $local_domain_list = Array.new
#    $local_ips = Hash.new
#    $file_life_periods = Array.new
#    $app_env = Hash.new

    @file_life_periods_for_sort = Array.new
    @file_life_periods_label = Hash.new
    @file_life_period_second = Hash.new

    if session[:autorize]
      if session[:user_category]
        user_category = session[:user_category]
      else
        user_category = 3
      end
      session[:autorize] = nil
    else
      user_category = 3
    end

    # ここでセットしたユーザカテゴリをモデルのバリデーションでも使用する
    Thread.current[:user_category] = user_category

    @app_envs =
        AppEnv
        .where('category IN (0, ?)',
               user_category)

    @app_envs.each do |app_env|
      case app_env.key
      when 'FILE_LIFE_PERIOD'
        @file_life_periods_for_sort.push [app_env.id, app_env.value.to_i]
        @file_life_periods_label[app_env.id] = app_env.note
        @file_life_period_second[app_env.id] = app_env.value
      when 'LOCAL_IPS'
        @local_ips << app_env
      when 'LOCAL_DOMAINS'
        @local_domain_list.push app_env.value
        @local_domains.concat app_env.value + "|"
      else
        @params_app_env[app_env.key] = app_env.value
      end
    end

    @file_life_periods_for_sort =
            @file_life_periods_for_sort.sort{|a ,b| a[1] <=> b[1]}
    @file_life_periods_for_sort.each do |buff|
      if @file_life_periods_for_sort.size > @file_life_periods.size
        @file_life_periods.push [@file_life_periods_label[buff[0]], buff[1]]
      end
    end

    @params_app_env['FLPD_VALUE'] =
            @file_life_period_second[@params_app_env['FILE_LIFE_PERIOD_DEF'].to_i]
    @params_app_env['FLPD_LABEL'] =
            @file_life_periods_label[@params_app_env['FILE_LIFE_PERIOD_DEF'].to_i]

    unless @local_domains == ""
      @local_domains.chop!
    end
  end

  def get_virus_status(tmp_path)
#    virus_status = nil
    virus_status = t("virus_check_status.error")
    clamd_service_down_status = false
    clamd_service_down_status1 = false
    clamd_service_down_status2 = false
    clamd_service_down_status3 = false
    clamd_service_error = false
    output_str = ""
    begin
      output, err, status = Open3.capture3("clamdscan #{tmp_path}")
      for str in err.split(/\n|\r\n|\r/)
        output_str += str
        if str.include?("ERROR: Could not connect to clamd on LocalSocket") && str.include?("clamd.sock: No such file or directory")
          clamd_service_down_status = true
        end
        if str.include?("ERROR: Could not connect to clamd on LocalSocket")
          clamd_service_down_status1 = true
        end
        if str.include?("clamd.sock: No such file or directory")
          clamd_service_down_status2 = true
        end
        if str.include?("ERROR: Could not lookup : Servname not supported for ai_socktype")
          clamd_service_down_status3 = true
        end
      end
      for str in output.split(/\n|\r\n|\r/)
        if str.include?(tmp_path)
          if str.include?("#{tmp_path}: OK")
            virus_status = '0'
          else
            virus_status = str.sub!(/#{tmp_path}:\ /, '').sub!(/\ FOUND/, '')
          end
        end
        if str.include?("Total errors:")
          clamd_service_error = true
        end
      end
      if clamd_service_error == true
        virus_status = t("virus_check_status.error")
      end
      if clamd_service_down_status1 == true && clamd_service_down_status2 == true
        virus_status = t("virus_check_status.virus_check_down")
      end
      if clamd_service_down_status == true && clamd_service_error == true
        virus_status = t("virus_check_status.virus_check_down")
      end
      if clamd_service_down_status3 == true
        virus_status = t("virus_check_status.virus_check_down")
      end
    rescue
      virus_status = t("virus_check_status.error")
    end
#    virus_status = output_str
    return virus_status
  end

  def initialize_value_for_operation
    $content_item_category = [['見出し', 1], ['文', 2], ['画像', 3],
            ['リンク', 4], ['画像リンク', 5]]
  end

  #  ファイル削除
  def vacuum_file_for_file_exchange
#    @file_dir = AppEnv.find(:first, :conditions => {
#             :key => "FILE_DIR"})
    @file_dir =
        AppEnv
        .where(:key => "FILE_DIR")
        .first
#    @send_files = Attachment.find(:all,
#            :select => "attachments.id as id, " +
#              "send_matters.created_at as created_at, " +
#              "send_matters.file_life_period as file_life_period",
#            :joins => "left outer join send_matters " +
#              "on attachments.send_matter_id = send_matters.id")
    @send_files = Attachment
    .select("attachments.id as id, " +
           "send_matters.created_at as created_at, " +
           "send_matters.file_life_period as file_life_period")
    .joins("left outer join send_matters " +
           "on attachments.send_matter_id = send_matters.id")

#    @request_files = RequestedAttachment.find(:all,
#            :select => "requested_attachments.id as id, " +
#              "requested_matters.created_at as created_at, " +
#              "requested_matters.file_life_period as file_life_period",
#            :joins => "left outer join requested_matters " +
#              "on requested_attachments.requested_matter_id =" +
#              "requested_matters.id")
    @request_files =
        RequestedAttachment
        .select("requested_attachments.id as id, " +
              "requested_matters.created_at as created_at, " +
              "requested_matters.file_life_period as file_life_period")
        .joins("left outer join requested_matters " +
              "on requested_attachments.requested_matter_id =" +
              "requested_matters.id")

#    @repare_data_request_files = RequestedMatter.find(:all,
#            :select => "distinct requested_matters.id as id",
#            :joins => "left outer join requested_attachments " +
#              "on requested_attachments.requested_matter_id = " +
#              "requested_matters.id",
#            :conditions => [ "requested_matters.file_up_date is null " +
#              "and requested_attachments.id is not null " +
#              "and requested_attachments.created_at < ADDDATE(LOCALTIME(), -1)" ])
    @repare_data_request_files =
        RequestedMatter
        .select("distinct requested_matters.id as id")
        .joins("left outer join requested_attachments " +
              "on requested_attachments.requested_matter_id = " +
              "requested_matters.id")
        .where( "requested_matters.file_up_date is null " +
              "and requested_attachments.id is not null " +
              "and requested_attachments.created_at < ADDDATE(LOCALTIME(), -1)")

    @repare_data_request_files.each do | repare_data_request_file |
      @requested_matter = RequestedMatter.find_by(id: repare_data_request_file.id)
      if @requested_matter.present?
        @requested_matter.file_life_period = 3600
        @requested_matter.file_up_date = @requested_matter.created_at
        app_env = AppEnv.where(key: 'PW_LENGTH_MIN', category: 3).first
        min = app_env.try(:value).to_i
        @requested_matter.receive_password = generate_random_string_values(rand(10000).to_s).slice(1,min)
        @requested_matter.password_notice = 1
        @requested_matter.download_check = 1
        @requested_matter.save
      end
    end

#    @vaccumed_send_files1 = Attachment.find(:all,
#            :select => "attachments.id as id, " +
#              "send_matters.created_at as created_at, " +
#              "send_matters.file_life_period as file_life_period",
#            :joins => "left outer join send_matters " +
#              "on attachments.send_matter_id = send_matters.id",
#            :conditions => [ "attachments.created_at < ADDDATE(LOCALTIME(), -1) " +
#              "and attachments.send_matter_id is null" ])
    @vaccumed_send_files1 =
        Attachment
        .select("attachments.id as id, " +
              "send_matters.created_at as created_at, " +
              "send_matters.file_life_period as file_life_period")
        .joins("left outer join send_matters " +
              "on attachments.send_matter_id = send_matters.id")
        .where("attachments.created_at < ADDDATE(LOCALTIME(), -1) " +
              "and attachments.send_matter_id is null")

    @vaccumed_send_files1.each do | file |
      filename = @params_app_env['FILE_DIR'] + "/" + file.id.to_s
      if File.exist?(filename)
        File.delete(filename)
      end
    end

    keep_term = 7
#    @vaccumed_send_files2 = Attachment.find(:all,
#            :select => "attachments.id as id, " +
#              "send_matters.created_at as created_at, " +
#              "send_matters.file_life_period as file_life_period, " +
#              "(LOCALTIME() - INTERVAL #{keep_term} DAY) as time1, " +
#              "LOCALTIME() as ctime, " +
#              "(LOCALTIME() - INTERVAL #{keep_term} DAY - " +
#              "INTERVAL send_matters.file_life_period SECOND) as time2",
#            :joins => "left outer join send_matters " +
#              "on attachments.send_matter_id = send_matters.id",
#            :conditions => [ "send_matters.created_at < " +
#              "LOCALTIME() - INTERVAL #{keep_term} DAY - " +
#              "INTERVAL send_matters.file_life_period SECOND " ])
    @vaccumed_send_files2 =
        Attachment
        .select("attachments.id AS id, " +
              "send_matters.created_at AS created_at, " +
              "send_matters.file_life_period AS file_life_period, " +
              "(LOCALTIME() - INTERVAL #{keep_term} DAY) AS time1, " +
              "LOCALTIME() AS ctime, " +
              "(LOCALTIME() - INTERVAL #{keep_term} DAY - " +
              "INTERVAL send_matters.file_life_period SECOND) AS time2")
        .joins("left outer join send_matters " +
              "on attachments.send_matter_id = send_matters.id")
        .where("send_matters.created_at < " +
              "LOCALTIME() - INTERVAL #{keep_term} DAY - " +
              "INTERVAL send_matters.file_life_period SECOND ")

    @vaccumed_send_files2.each do | file |
      filename = @params_app_env['FILE_DIR'] + "/" + file.id.to_s
      if File.exist?(filename)
        File.delete(filename)
      end
    end

    keep_term = 7
#    @vaccumed_request_files = RequestedAttachment.find(:all,
#            :select => "requested_attachments.id as id, " +
#              "requested_matters.created_at as created_at, " +
#              "requested_matters.file_life_period as file_life_period, " +
#              "(LOCALTIME() - INTERVAL #{keep_term} DAY) as time1, " +
#              "LOCALTIME() as ctime, " +
#              "(LOCALTIME() - INTERVAL #{keep_term} DAY - " +
#              "INTERVAL requested_matters.file_life_period SECOND) as time2",
#            :joins => "left outer join requested_matters " +
#              "on requested_attachments.requested_matter_id = " +
#              "requested_matters.id",
#            :conditions => [ "requested_matters.created_at < " +
#              "LOCALTIME() - INTERVAL #{keep_term} DAY - " +
#              "INTERVAL requested_matters.file_life_period SECOND " ])
    @vaccumed_request_files =
        RequestedAttachment
        .select("requested_attachments.id AS id, " +
              "requested_matters.created_at AS created_at, " +
              "requested_matters.file_life_period AS file_life_period, " +
              "(LOCALTIME() - INTERVAL #{keep_term} DAY) AS time1, " +
              "LOCALTIME() AS ctime, " +
              "(LOCALTIME() - INTERVAL #{keep_term} DAY - " +
              "INTERVAL requested_matters.file_life_period SECOND) AS time2")
        .joins("left outer join requested_matters " +
              "on requested_attachments.requested_matter_id = " +
              "requested_matters.id")
        .where("requested_matters.file_up_date < " +
              "LOCALTIME() - INTERVAL #{keep_term} DAY - " +
              "INTERVAL requested_matters.file_life_period SECOND ")

    @vaccumed_request_files.each do | file |
      filename = @params_app_env['FILE_DIR'] + "/r" + file.id.to_s
      if File.exist?(filename)
        File.delete(filename)
      end
    end
  end

  #  データ削除
  def vacuum_data_for_file_exchange
    current_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")

    keep_term = 12
    cond1_for_send = "created_at < '#{current_time}' -" +
                     " INTERVAL '#{keep_term}' MONTH"
    cond2_for_send = "send_matter_id in (select id from send_matters " +
            "where " + cond1_for_send + ")"
    cond3_for_send = "send_matter_id in (select id from send_matters " +
            "where " + cond1_for_send + ")"
    cond4_for_send = "attachment_id in (select id from attachments " +
            "where " + cond3_for_send + ")"
    cond5_for_send = "file_dl_check_id in (select id from file_dl_checks " +
            "where " + cond4_for_send + ")"

#    FileDlLog.delete_all([ cond5_for_send ])
#    FileDlCheck.delete_all([ cond4_for_send ])
#    Attachment.delete_all([ cond3_for_send ])
#    Receiver.delete_all([ cond2_for_send ])
#    SendMatter.delete_all([ cond1_for_send ])
    FileDlLog.where([ cond5_for_send ]).destroy_all
    FileDlCheck.where([ cond4_for_send ]).destroy_all
    Attachment.where([ cond3_for_send ]).destroy_all
    Receiver.where([ cond2_for_send ]).destroy_all
    SendMatter.where([ cond1_for_send ]).destroy_all

    cond1_for_requset = "created_at < '#{current_time}' - " +
            "INTERVAL '#{keep_term}' MONTH"
    cond2_for_requset =  "request_matter_id in " +
            "(select id from request_matters " +
            "where "  + cond1_for_requset + ")"
    cond3_for_requset =  "requested_matter_id in " +
            "(select id from requested_matters " +
            "where " + cond2_for_requset + ")"
    cond4_for_requset =  "requested_attachment_id in " +
            "(select id from requested_attachments " +
            "where " + cond3_for_requset + ")"

#    RequestedFileDlLog.delete_all([ cond4_for_requset ])
#    RequestedAttachment.delete_all([ cond3_for_requset ])
#    RequestedMatter.delete_all([ cond2_for_requset ])
#    RequestMatter.delete_all([ cond1_for_requset ])
    RequestedFileDlLog.where([ cond4_for_requset ]).destroy_all
    RequestedAttachment.where([ cond3_for_requset ]).destroy_all
    RequestedMatter.where([ cond2_for_requset ]).destroy_all
    RequestMatter.where([ cond1_for_requset ]).destroy_all
  end

  def get_moderate_flag()
    if session[:user_id].present? && current_user.present?
      if current_user.moderate.present?
        @moderate = current_user.moderate
        moderate_flag = 1
      else
        moderate_flag = 0
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
          moderate_flag = 1
        else
          moderate_flag = 0
        end
      else
        moderate_flag = 0
      end
    end
    return moderate_flag
  end
end
