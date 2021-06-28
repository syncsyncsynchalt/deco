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
  self.allow_forgery_protection = false
  include AuthenticatedSystem
  include Nmt
  helper :all

  $content_item_category = Array.new

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  # protect_from_forgery # :secret => 'c0684971bb7bbaafeaeb5d7f0cb6d10c'

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  # filter_parameter_logging :password

  # check IP and login user
  def authorize
    session[:autorize] = 'yes'
    @local_ips = AppEnv.find(:all, :conditions => {'key' => 'LOCAL_IPS' })
    @access_ip = request.env['HTTP_X_FORWARDED_FOR']
    unless @access_ip
      @access_ip = request.env['REMOTE_ADDR']
    end

    if @local_ips.select{ |local_ip|
            IPAddr.new(local_ip.value).include?(@access_ip) }.size > 0
      session[:user_category] = 3

      if logged_in?
        user = User.find(:all, :conditions => {
                :category => 1, :login => current_user.login })
        if user.length == 0
          self.current_user.forget_me if logged_in?
          cookies.delete :auth_token
        end
      end
    else
      if logged_in?
        session[:user_category] = 2
      else
        redirect_to :controller => "sessions", :action => "new"
      end
    end
  end

  # check login user for administrator
  def administrator_authorize
    users = User.find(:all, :conditions => { :category => 1 })

    if users.length > 0
      if logged_in?
        user = User.find(:all, :conditions => { :category => 1,
                :login => current_user.login })
        if user.length == 0
          self.current_user.forget_me if logged_in?
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
      if logged_in?
        self.current_user.forget_me if logged_in?
        cookies.delete :auth_token
        reset_session
      end
    end
  end

  # check IP in administrator
  def check_ip_for_administrator
    @local_ips = AppEnv.find(:all,
            :conditions => {  'key' => 'PERMIT_OPERATION_IPS' })
    @access_ip = request.env['HTTP_X_FORWARDED_FOR']
    unless @access_ip
      @access_ip = request.env['REMOTE_ADDR']
    end

    unless @local_ips.select{ |local_ip|
            IPAddr.new(local_ip.value).include?(@access_ip) }.size > 0
      render :text => "このIPアドレス（#{@access_ip}）は許可されていません。"
    end
  end

  # 環境変数を読み込む
  def load_env
    $local_domains = ""
    $local_domain_list = Array.new
    $local_ips = Hash.new
    $file_life_periods = Array.new
    $app_env = Hash.new

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

    @app_envs = AppEnv.find(:all,
                            :conditions =>
                              ['category = 0 or category = ?',
                               user_category])

    @app_envs.each do |app_env|
      case app_env.key
      when 'FILE_LIFE_PERIOD'
        @file_life_periods_for_sort.push [app_env.id, app_env.value.to_i]
        @file_life_periods_label[app_env.id] = app_env.note
        @file_life_period_second[app_env.id] = app_env.value
      when 'LOCAL_IPS'
        $local_ips = app_env
      when 'LOCAL_DOMAINS'
        $local_domain_list.push app_env.value
        $local_domains.concat app_env.value + "|"
      else
        $app_env[app_env.key] = app_env.value
      end
    end

    @file_life_periods_for_sort =
            @file_life_periods_for_sort.sort{|a ,b| a[1] <=> b[1]}
    @file_life_periods_for_sort.each do |buff|
      if @file_life_periods_for_sort.size > $file_life_periods.size
        $file_life_periods.push [@file_life_periods_label[buff[0]], buff[1]]
      end
    end

    $app_env['FLPD_VALUE'] =
            @file_life_period_second[$app_env['FILE_LIFE_PERIOD_DEF'].to_i]
    $app_env['FLPD_LABEL'] =
            @file_life_periods_label[$app_env['FILE_LIFE_PERIOD_DEF'].to_i]

    unless $local_domains == ""
      $local_domains.chop!
    end
  end

  def initialize_value_for_operation
    $content_item_category = [['見出し', 1], ['文', 2], ['画像', 3],
            ['リンク', 4], ['画像リンク', 5]]
  end

  #  ファイル削除
  def vacuum_file_for_file_exchange
    @file_dir = AppEnv.find(:first, :conditions => {
             :key => "FILE_DIR"})
    @send_files = Attachment.find(:all,
            :select => "attachments.id as id, " + 
              "send_matters.created_at as created_at, " +
              "send_matters.file_life_period as file_life_period",
            :joins => "left outer join send_matters " +
              "on attachments.send_matter_id = send_matters.id")

    @request_files = RequestedAttachment.find(:all,
            :select => "requested_attachments.id as id, " + 
              "requested_matters.created_at as created_at, " +
              "requested_matters.file_life_period as file_life_period",
            :joins => "left outer join requested_matters " +
              "on requested_attachments.requested_matter_id =" +
              "requested_matters.id")

    @repare_data_request_files = RequestedMatter.find(:all,
            :select => "distinct requested_matters.id as id",
            :joins => "left outer join requested_attachments " +
              "on requested_attachments.requested_matter_id = " +
              "requested_matters.id",
            :conditions => [ "requested_matters.file_up_date is null " +
              "and requested_attachments.id is not null" ])

    @repare_data_request_files.each do | requested_matter_id |
      @requested_matter = RequestedMatter.find(requested_matter_id)
      @requested_matter.file_life_period = 0
      @requested_matter.file_up_date = @requested_matter.created_at
      @requested_matter.save
    end

    @vaccumed_send_files1 = Attachment.find(:all,
            :select => "attachments.id as id, " + 
              "send_matters.created_at as created_at, " +
              "send_matters.file_life_period as file_life_period",
            :joins => "left outer join send_matters " +
              "on attachments.send_matter_id = send_matters.id",
            :conditions => [ "attachments.created_at < ADDDATE(LOCALTIME(), -1) " +
              "and attachments.send_matter_id is null" ])

    @vaccumed_send_files1.each do | file |
      filename = $app_env['FILE_DIR'] + "/" + file.id.to_s
      if File.exist?(filename)
        File.delete(filename)
      end
    end

    keep_term = 7
    @vaccumed_send_files2 = Attachment.find(:all,
            :select => "attachments.id as id, " + 
              "send_matters.created_at as created_at, " +
              "send_matters.file_life_period as file_life_period, " +
              "(LOCALTIME() - INTERVAL #{keep_term} DAY) as time1, " +
              "LOCALTIME() as ctime, " +
              "(LOCALTIME() - INTERVAL #{keep_term} DAY - " +
              "INTERVAL send_matters.file_life_period SECOND) as time2",
            :joins => "left outer join send_matters " +
              "on attachments.send_matter_id = send_matters.id",
            :conditions => [ "send_matters.created_at < " +
              "LOCALTIME() - INTERVAL #{keep_term} DAY - " +
              "INTERVAL send_matters.file_life_period SECOND " ])

    @vaccumed_send_files2.each do | file |
      filename = $app_env['FILE_DIR'] + "/" + file.id.to_s
      if File.exist?(filename)
        File.delete(filename)
      end
    end

    keep_term = 7
    @vaccumed_request_files = RequestedAttachment.find(:all,
            :select => "requested_attachments.id as id, " + 
              "requested_matters.created_at as created_at, " +
              "requested_matters.file_life_period as file_life_period, " +
              "(LOCALTIME() - INTERVAL #{keep_term} DAY) as time1, " +
              "LOCALTIME() as ctime, " +
              "(LOCALTIME() - INTERVAL #{keep_term} DAY - " +
              "INTERVAL requested_matters.file_life_period SECOND) as time2",
            :joins => "left outer join requested_matters " +
              "on requested_attachments.requested_matter_id = " +
              "requested_matters.id",
            :conditions => [ "requested_matters.created_at < " +
              "LOCALTIME() - INTERVAL #{keep_term} DAY - " +
              "INTERVAL requested_matters.file_life_period SECOND " ])

    @vaccumed_request_files.each do | file |
      filename = $app_env['FILE_DIR'] + "/r" + file.id.to_s
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

    FileDlLog.delete_all([ cond5_for_send ])
    FileDlCheck.delete_all([ cond4_for_send ])
    Attachment.delete_all([ cond3_for_send ])
    Receiver.delete_all([ cond2_for_send ])
    SendMatter.delete_all([ cond1_for_send ])

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

    RequestedFileDlLog.delete_all([ cond4_for_requset ])
    RequestedAttachment.delete_all([ cond3_for_requset ])
    RequestedMatter.delete_all([ cond2_for_requset ])
    RequestMatter.delete_all([ cond1_for_requset ])
  end
end
