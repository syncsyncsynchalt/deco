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
class SysLogController < ApplicationController
  require "rubygems"
  require "mysql2"
  layout 'system_admin'
  before_filter :check_ip_for_administrator, :administrator_authorize
  before_filter :load_env
  $database = ""
  # 送信ログ
  def send_log
    @time1 = Time.now.strftime("%Y/%m/%d %H:%M:%S")
    session[:section_title] = '送信ログ閲覧'

    if params[:id]
      @page = params[:id].to_i
    else
      @page = 1
      session[:search_type] = nil
      session[:search_word] = nil
    end

    condition1 = ""
    condition2 = ""
    condition = ""
    @type = 0
    if session[:search_type]
      @type = session[:search_type]
    end

    if params[:type]
      @type = params[:type]
      session[:search_type] = @type
    end

    if session[:search_word]
      @keyward = session[:search_word]
    end

    if params[:keyward]
      @keyward = params[:keyward]
      session[:search_word] = @keyward
    end

    case @type.to_i
    when 1
      condition1 = "send_matters.name like '%" + @keyward.to_s + "%'"
      sqlstr = "select * from send_matters where " + condition1
#      @rs = db.query sqlstr
      @rs = SendMatter.find_by_sql(sqlstr)
      @total_data = @rs.length
    when 2
      condition1 = "send_matters.mail_address like '%" +
              @keyward.to_s + "%'"
      sqlstr = "select * from send_matters where " + condition1
#      @rs = db.query sqlstr
      @rs = SendMatter.find_by_sql(sqlstr)
      @total_data = @rs.length
    when 3
      condition2 = "receivers.name like '%" + @keyward.to_s + "%'"
      sqlstr = "select distinct(send_matters.id) " +
              "from send_matters " +
              "left outer join receivers " +
              "on send_matters.id = receivers.send_matter_id " +
              "where " + condition2
#      @rs = db.query sqlstr
      @rs = SendMatter.find_by_sql(sqlstr)
      @total_data = @rs.length
    when 4
      condition2 = "receivers.mail_address like '%" + @keyward.to_s + "%'"
      sqlstr = "select distinct(send_matters.id) " +
              "from send_matters " +
              "left outer join receivers " +
              "on send_matters.id = receivers.send_matter_id " +
              "where " + condition2
#      @rs = db.query sqlstr
      @rs = SendMatter.find_by_sql(sqlstr)
      @total_data = @rs.length
    else
      sqlstr = "select * from send_matters "
#      @rs = db.query sqlstr
      @rs = SendMatter.find_by_sql(sqlstr)
      @total_data = @rs.length
    end

    if condition == ""
      unless condition1 == ""
        condition = condition1
      end

      unless condition2 == ""
        condition = condition2
      end
    else
      unless condition1 == ""
        condition += " and " + condition1
      end

      unless condition2 == ""
        condition += " and " + condition2
      end
    end

    unless condition == ""
      condition = " where " + condition + " "
    end
    @amt_data = 100

    @total_page = (@total_data/@amt_data).to_i
    unless @total_data % @amt_data == 0 
      @total_page = @total_page + 1
    end

    if @page > @total_page
      @page = 1
    elsif @page <= 0
      @page = 1
    end

    @s_data = (@page - 1) * @amt_data + 1
    @e_data = @page * @amt_data

    @select_month = Array.new
    @select_month.push ["選んで下さい", 0]
    sqlstr_for_csv = "select distinct DATE_FORMAT(created_at, \'%Y%m\') as m " +
            "from send_matters order by m desc"
    @rs = SendMatter.find_by_sql(sqlstr_for_csv)
    @rs.each do | data |
      year = data.m.slice(0, 4).to_i
      mon = data.m.slice(4, 2).to_i
      @select_month.push [year.to_s + '年' + mon.to_s + '月', data.m]
    end

    @part_of_page = original_paginate('sys_log', 'send_log', @page,
            @total_page, 4, 2)

    case @type.to_i
    when  3, 4
      sqlstr = "select " +
          "tbl1.sub_id as send_matter_id, " +
          "tbl1.created_at " +
            "as created_at, " +
          "tbl1.sender_name as sender_name, " +
          "tbl1.mail_address as sender_mail_address, " +
          "receivers.name as receiver_name, " +
          "receivers.mail_address as receiver_mail_address, " +
          "tbl1.total_file as total_file, " +
          "tbl1.total_size as total_size, " +
          "tbl1.data_order as data_order " +
          "from " +
            "(select " + 
            "tbl2.id as sub_id, " +
            "tbl2.created_at as created_at, " +
            "tbl2.name as sender_name, " +
            "tbl2.mail_address as mail_address, " +
            "tbl2.data_order as data_order, " +
            "count(attachments.id) as total_file, " +
            "sum(attachments.size) as total_size " +
            "from " +
              "(select " +
              "distinct(send_matters.id) as id, " +
              "send_matters.created_at as created_at, " +
              "send_matters.name as name, " +
              "send_matters.mail_address as mail_address, " +
              "1 as data_order " +
              "from send_matters " +
              "left outer join receivers " +
              "on send_matters.id = receivers.send_matter_id " +
              condition +
              "order by send_matters.created_at desc " +
              "limit " + (@s_data - 1).to_s + ", " + @amt_data.to_s + " " +
              ") as tbl2 " +
            "left outer join attachments " +
            "on tbl2.id = attachments.send_matter_id " +
            "group by " +
            "tbl2.id, tbl2.created_at, sender_name, mail_address, data_order" +
            ") as tbl1 " +
          "left outer join receivers " +
          "on tbl1.sub_id = receivers.send_matter_id " +
          "where " + condition2 +
          "order by tbl1.created_at desc"
    else
      sqlstr = "select " +
          "tbl1.sub_id as send_matter_id, " +
          "tbl1.created_at " +
            "as created_at, " +
          "tbl1.sender_name as sender_name, " +
          "tbl1.mail_address as sender_mail_address, " +
          "receivers.name as receiver_name, " +
          "receivers.mail_address as receiver_mail_address, " +
          "tbl1.total_file as total_file, " +
          "tbl1.total_size as total_size, " +
          "tbl1.data_order as data_order " +
          "from " +
            "(select " + 
            "tbl2.id as sub_id, " +
            "tbl2.created_at as created_at, " +
            "tbl2.name as sender_name, " +
            "tbl2.mail_address as mail_address, " +
            "tbl2.data_order as data_order, " +
            "count(attachments.id) as total_file, " +
            "sum(attachments.size) as total_size " +
            "from " +
              "(select " +
              "id, created_at, name, mail_address, 1 as data_order " +
              "from send_matters " + condition +
              "order by created_at desc " +
              "limit " + (@s_data - 1).to_s + ", " + @amt_data.to_s + " " +
              ") as tbl2 " +
            "left outer join attachments " +
            "on tbl2.id = attachments.send_matter_id " +
            "group by " +
            "tbl2.id, tbl2.created_at, sender_name, mail_address, data_order" +
            ") as tbl1 " +
          "left outer join receivers " +
          "on tbl1.sub_id = receivers.send_matter_id " +
          "order by tbl1.created_at desc"
    end

    session[:debug] = sqlstr
    @time2 = Time.now.strftime("%Y/%m/%d %H:%M:%S")
    
#    @rs = db.query sqlstr
    @rs = SendMatter.find_by_sql(sqlstr)

#    db.close if db
    @time3 = Time.now.strftime("%Y/%m/%d %H:%M:%S")

  end

  # 受信ログ
  def receive_log
    session[:section_title] = '受信ログ閲覧'

    condition1 = ""
    condition2 = ""
    if params[:type]
      @type = params[:type]
    end

    if params[:keyward]
      @keyward = params[:keyward]
      case @type.to_i
      when 0
        condition1 = " and receivers.name like '%" + @keyward.to_s + "%'"
        condition2 = " and request_matters.name like '%" + @keyward.to_s + "%'"
      when 1
        condition1 = " and receivers.mail_address like '%" + @keyward.to_s + "%'"
        condition2 = " and request_matters.mail_address like '%" +
                @keyward.to_s + "%'"
      end
    end

    @select_month = Array.new
    @select_month.push ["選んで下さい", 0]
    sqlstr_for_csv = "select distinct DATE_FORMAT(created_at, \'%Y%m\') as m " +
            "from file_dl_logs " +
            "union distinct " +
            "select distinct DATE_FORMAT(created_at, \'%Y%m\') as m " +
            "from requested_file_dl_logs " +
            "order by m desc"
    @rs = Receiver.find_by_sql(sqlstr_for_csv)
    @rs.each do | data |
      year = data.m.slice(0, 4).to_i
      mon = data.m.slice(4, 2).to_i
      @select_month.push [year.to_s + '年' + mon.to_s + '月', data.m]
    end

    if params[:id]
      @page = params[:id].to_i
    else
      @page = 1
    end

    if @page <= 0
      @page = 1
    end

    @amt_data = 100

    sqlstr_sub1 = "select " +
          "convert_tz(tbl1.dl_at, '+00:00', '+09:00') " +
            "as dl_at, " +
          "'送信' as flg, " +
          "receivers.name as receiver_name, " +
          "receivers.mail_address as receiver_mail_address, " +
          "attachments.name as file_name, " +
          "attachments.size as file_size " +
          "from attachments, receivers, send_matters, " +
            "(select " +
            "file_dl_checks.id as id, " +
            "file_dl_logs.created_at as dl_at, " +
            "file_dl_checks.receiver_id as receiver_id, " +
            "file_dl_checks.attachment_id as attachment_id " +
            "from file_dl_logs " +
            "left outer join file_dl_checks " +
            "on file_dl_logs.file_dl_check_id = file_dl_checks.id) as tbl1 " +
          "where attachments.id = tbl1.attachment_id " +
          "and receivers.id = tbl1.receiver_id " +
          "and send_matters.id = attachments.send_matter_id" +
          condition1

    sqlstr_sub2 = "select " +
          "convert_tz(requested_file_dl_logs.created_at, " +
            "'+00:00', '+09:00') as dl_at, " +
          "'依頼' as flg, " +
          "request_matters.name as receiver_name, " +
          "request_matters.mail_address as receiver_mail_address, " +
          "requested_attachments.name as file_name, " +
          "requested_attachments.size as file_size " +
          "from request_matters, requested_matters, " +
          " requested_file_dl_logs, requested_attachments " +
          "where requested_file_dl_logs.requested_attachment_id = " +
          "requested_attachments.id " +
          "and requested_attachments.requested_matter_id = " +
          "requested_matters.id " +
          "and requested_matters.request_matter_id = request_matters.id" +
          condition2

    sqlstr = sqlstr_sub1 + " union all " + sqlstr_sub2 + " order by dl_at desc"

    @sql = sqlstr
#    @rs = db.query sqlstr
    @rs = Receiver.find_by_sql(sqlstr)

    @total_data = @rs.length

    @total_page = (@total_data/@amt_data).to_i
    unless @total_data % @amt_data == 0 
      @total_page = @total_page + 1
    end

    if @page > @total_page
      @page = 1
    end

    @s_data = (@page - 1) * @amt_data + 1
    @e_data = @page * @amt_data

    @part_of_page = original_paginate('sys_log', 'receive_log', @page,
            @total_page, 4, 2)

#    db.close if db
  end

  # 依頼ログ
  def request_log
    session[:section_title] = '依頼ログ閲覧'

    condition = ""

    if params[:type]
      @type = params[:type]
    end

    if params[:keyward]
      @keyward = params[:keyward]

      unless condition == ""
        condition = " and " + condition + " "
      end

      case @type.to_i
      when 0
        condition = "where request_matters.name like '%" + @keyward.to_s + "%'" +
                condition

        sqlstr = "select * from request_matters " + condition
#        @rs = db.query sqlstr
        @rs = RequestMatter.find_by_sql(sqlstr)
        @total_data = @rs.length
      when 1
        condition = "where request_matters.mail_address like '%" +
                @keyward.to_s + "%'" + condition

        sqlstr = "select * from request_matters " + condition
#        @rs = db.query sqlstr
        @rs = RequestMatter.find_by_sql(sqlstr)
        @total_data = @rs.length
      when 2
        condition = "where requested_matters.name like '%" +
                @keyward.to_s + "%'" + condition
        sqlstr = "select distinct(request_matters.id) from request_matters " +
               "left outer join requested_matters " +
               "on request_matters.id = requested_matters.request_matter_id " +
                condition
        @sql = sqlstr
#        @rs = db.query sqlstr
        @rs = RequestMatter.find_by_sql(sqlstr)
        @total_data = @rs.length
      when 3
        condition = "where requested_matters.mail_address like '%" +
                @keyward.to_s + "%'" + condition
        sqlstr = "select distinct(request_matters.id) from request_matters " +
               "left outer join requested_matters " +
               "on request_matters.id = requested_matters.request_matter_id " +
                condition
        @sql = sqlstr
#        @rs = db.query sqlstr
        @rs = RequestMatter.find_by_sql(sqlstr)
        @total_data = @rs.length
      end
    else
      unless condition == ""
        condition = " where " + condition + " "
      end

      sqlstr = "select * from request_matters" + condition
#      @rs = db.query sqlstr
      @rs = RequestMatter.find_by_sql(sqlstr)
      @total_data = @rs.length
    end

    if params[:id]
      @page = params[:id].to_i
    else
      @page = 1
    end

    if @page <= 0
      @page = 1
    end

    @amt_data = 100

    @total_page = (@total_data/@amt_data).to_i
    unless @total_data % @amt_data == 0 
      @total_page = @total_page + 1
    end

    if @page > @total_page
      @page = 1
    end

    @s_data = (@page - 1) * @amt_data + 1
    @e_data = @page * @amt_data

    @select_month = Array.new
    @select_month.push ["選んで下さい", 0]
    sqlstr_for_csv = "select distinct DATE_FORMAT(created_at, \'%Y%m\') as m " +
            "from request_matters order by m desc"
#    @rs = db.query sqlstr_for_csv
    @rs = RequestMatter.find_by_sql(sqlstr_for_csv)
    @rs.each do | data |
      year = data.m.slice(0, 4).to_i
      mon = data.m.slice(4, 2).to_i
      @select_month.push [year.to_s + '年' + mon.to_s + '月', data.m]
    end

    @part_of_page = original_paginate('sys_log', 'request_log', @page,
            @total_page, 4, 2)

    sqlstr = "select " +
            "request_matters.id as request_matter_id, " +
            "request_matters.name as request_name, " +
            "request_matters.mail_address as request_mail_address, " +
            "request_matters.created_at " +
              "as created_at, " +
            "requested_matters.id as requested_matter_id, " +
            "requested_matters.name as requested_name, " +
            "requested_matters.mail_address as requested_mail_address " +
            "from request_matters " +
            "left outer join requested_matters " +
            "on request_matters.id = " +
              "requested_matters.request_matter_id " +
            condition +
            "order by request_matters.created_at desc"

#    @rs = db.query sqlstr
    @rs = RequestMatter.find_by_sql(sqlstr)

#    db.close if db

  end

  # 送信ログをcsvファイルに出力
  def get_csv_of_send_log
    rslt = 0

    condition = ""

    year_mon = params[:month_for_out]
    if year_mon.to_i == 0
      rslt = 1
    else
      year = year_mon.slice(0, 4).to_i
      mon = year_mon.slice(4, 2).to_i
      time = Time.mktime year, mon
      if condition == ""
        condition = "where "
      else
        condition = condition + "and "
      end
      condition = condition + "created_at BETWEEN '" + (time.strftime("%Y-%m-%d %H:%M:%S")) + "'" +
              "and '" + (time.at_end_of_month.strftime("%Y-%m-%d %H:%M:%S")) + "' "
    end

    deletefiles = Dir.glob($app_env['FILE_DIR'] + '/log_send_' + '*')
    deletefiles.each do |deletefile|
      File.delete(deletefile)
    end

    if rslt == 0
      sqlstr = "select " +
            "tbl1.sub_id as send_matter_id, " +
            "tbl1.created_at " +
              "as created_at, " +
            "tbl1.sender_name as sender_name, " +
            "tbl1.mail_address as sender_mail_address, " +
            "receivers.name as receiver_name, " +
            "receivers.mail_address as receiver_mail_address, " +
            "tbl1.total_file as total_file, " +
            "tbl1.total_size as total_size, " +
            "tbl1.data_order as data_order " +
            "from " +
              "(select " + 
              "tbl2.id as sub_id, " +
              "tbl2.created_at as created_at, " +
              "tbl2.name as sender_name, " +
              "tbl2.mail_address as mail_address, " +
              "tbl2.data_order as data_order, " +
              "count(attachments.id) as total_file, " +
              "sum(attachments.size) as total_size " +
              "from " +
                "(select " +
                "id, created_at, name, mail_address, 1 as data_order " +
                "from send_matters " + condition +
                "order by created_at desc " +
                ") as tbl2 " +
              "left outer join attachments " +
              "on tbl2.id = attachments.send_matter_id " +
              "group by " +
              "tbl2.id, tbl2.created_at, sender_name, mail_address, data_order" +
              ") as tbl1 " +
            "left outer join receivers " +
            "on tbl1.sub_id = receivers.send_matter_id " +
            "order by tbl1.created_at desc"

      @rs = RequestMatter.find_by_sql(sqlstr)

      filename = 'log_send_' + Time.now.strftime("%Y-%m-%d_%H:%M:%S")
      filename_ws_pass = $app_env['FILE_DIR'] + '/' + filename
      filename_ws_pass = filename_ws_pass
      file = open(filename_ws_pass, 'w:shift_jis')
      file << '登録日,送信ＩＤ,送信者名,送信者メールアドレス,'
      file << '受信者名,受信者メールアドレス,総ファイル数,総ファイルサイズ' + "\n"

      @rs.each do | data |
        file << (Time.parse(data.created_at.to_s)).
                strftime("%Y/%m/%d %H:%M:%S") + ","
        file << data.send_matter_id.to_s + ","
        file << data.sender_name + ","
        file << data.sender_mail_address + ","
        if data.receiver_name
          file << data.receiver_name
        end
        file << ","
        if data.receiver_mail_address
          file << data.receiver_mail_address
        end
        file << ","
        file << data.total_file.to_s + ","
        file << data.total_size.to_s + "\n"
      end
      file.close

      filename = 'send_log.csv'
      send_file filename_ws_pass, :filename => filename, :type => "text/csv"

    else
      redirect_to :action => "send_log"
    end
  end

  # 受信ログをcsvファイルに出力
  def get_csv_of_receive_log
    rslt = 0

    condition1 = ""
    condition_day1 = ""
    condition2 = ""

    year_mon = params[:month_for_out]
    if year_mon.to_i == 0
      rslt = 1
    else
      year = year_mon.slice(0, 4).to_i
      mon = year_mon.slice(4, 2).to_i
      time = Time.mktime year, mon
      condition_day1 = "where file_dl_logs.created_at BETWEEN '" + (time.strftime("%Y-%m-%d")) + "'" +
              "and '" + (time.at_end_of_month.strftime("%Y-%m-%d")) + "' "
      condition2 = condition2 + " and requested_file_dl_logs.created_at BETWEEN \'" + (time.strftime("%Y-%m-%d")) + "\'" +
              "and '" + (time.at_end_of_month.strftime("%Y-%m-%d")) + "' "
    end

    deletefiles = Dir.glob($app_env['FILE_DIR'] + '/log_receive_' + '*')
    deletefiles.each do |deletefile|
      File.delete(deletefile)
    end

    if rslt == 0
      sqlstr_sub1 = "select " +
              "convert_tz(tbl1.dl_at, '+00:00', '+09:00') " +
                "as dl_at, " +
              "'送信' as flg, " +
              "receivers.name as receiver_name, " +
              "receivers.mail_address as receiver_mail_address, " +
              "attachments.name as file_name, " +
              "attachments.size as file_size " +
              "from attachments, receivers, send_matters, " +
                "(select " +
                "file_dl_checks.id as id, " +
                "file_dl_logs.created_at as dl_at, " +
                "file_dl_checks.receiver_id as receiver_id, " +
                "file_dl_checks.attachment_id as attachment_id " +
                "from file_dl_logs " +
                "left outer join file_dl_checks " +
                "on file_dl_logs.file_dl_check_id = file_dl_checks.id " +
                condition_day1 + ") as tbl1 " +
              "where attachments.id = tbl1.attachment_id " +
              "and receivers.id = tbl1.receiver_id " +
              "and send_matters.id = attachments.send_matter_id" +
              condition1

      sqlstr_sub2 = "select " +
              "convert_tz(requested_file_dl_logs.created_at, " +
              "'+00:00', '+9:00') as dl_at, " +
              "'依頼' as flg, " +
              "request_matters.name as receiver_name, " +
              "request_matters.mail_address as receiver_mail_address, " +
              "requested_attachments.name as file_name, " +
              "requested_attachments.size as file_size " +
              "from request_matters, requested_matters, " +
              " requested_file_dl_logs, requested_attachments " +
              "where requested_file_dl_logs.requested_attachment_id = " +
              "requested_attachments.id " +
              "and requested_attachments.requested_matter_id = " +
              "requested_matters.id " +
              "and requested_matters.request_matter_id = request_matters.id" +
              condition2

      sqlstr = sqlstr_sub1 + " union all " + sqlstr_sub2 + " order by dl_at desc"
      session[:debug] = sqlstr
      @rs = RequestMatter.find_by_sql(sqlstr)

      filename = 'log_receive_' + Time.now.strftime("%Y-%m-%d_%H:%M:%S")
      filename_ws_pass = $app_env['FILE_DIR'] + '/' + filename
      file = open(filename_ws_pass, 'w:shift_jis')
      file << 'ダウンロード日,区分,受信者,受信者メールアドレス,'
      file << 'ファイル名,ファイルサイズ' + "\n"

      @rs.each do | data |
        file << (Time.parse(data.dl_at.to_s)).
                strftime("%Y/%m/%d %H:%M:%S") + ","
        file << data.flg + ","
        file << data.receiver_name + ","
        file << data.receiver_mail_address + ","
        file << data.file_name + ","
        file << data.file_size.to_s + "\n"
      end
      file.close

      filename = 'receive_log.csv'
      send_file filename_ws_pass, :filename => filename, :type => "text/csv"
    else
      redirect_to :action => "receive_log"
    end
  end

  # 依頼ログをcsvファイルに出力
  def get_csv_of_request_log
    rslt = 0

    condition = ""

    # 日付の条件作成
    year_mon = params[:month_for_out]
    if year_mon.to_i == 0
      rslt = 1
    else
      year = year_mon.slice(0, 4).to_i
      mon = year_mon.slice(4, 2).to_i
      time = Time.mktime year, mon
      if condition == ""
        condition = "where "
      else
        condition = condition + "and "
      end
      condition = condition + "request_matters.created_at BETWEEN '" + (time.strftime("%Y-%m-%d")) + "' " +
              "and '" + (time.at_end_of_month.strftime("%Y-%m-%d")) + "' "
    end

    # 不要ログの削除
    deletefiles = Dir.glob($app_env['FILE_DIR'] + '/log_request_' + '*')
    deletefiles.each do |deletefile|
      File.delete(deletefile)
    end

    if rslt == 0
      sqlstr = "select " +
              "request_matters.id as request_matter_id, " +
              "request_matters.name as request_name, " +
              "request_matters.mail_address as request_mail_address, " +
              "request_matters.created_at " +
                "as created_at, " +
              "requested_matters.id as requested_matter_id, " +
              "requested_matters.name as requested_name, " +
              "requested_matters.mail_address as requested_mail_address " +
              "from request_matters " +
              "left outer join requested_matters on request_matters.id = " +
              "requested_matters.request_matter_id " +
              condition +
              "order by request_matters.created_at desc"

      @rs = RequestMatter.find_by_sql(sqlstr)

      filename = 'log_request_' + Time.now.strftime("%Y-%m-%d_%H:%M:%S")
      filename_ws_pass = $app_env['FILE_DIR'] + '/' + filename
      file = open(filename_ws_pass, 'w:shift_jis')
      file << '登録日,依頼ＩＤ,依頼人,依頼人メールアドレス,'
      file << '送信者名,送信者メールアドレス' + "\n"

      @rs.each do | data |
        file << (Time.parse(data.created_at.to_s)).
                strftime("%Y/%m/%d %H:%M:%S") + ","
        file << data.request_matter_id.to_s + ","
        file << data.request_name + ","
        file << data.request_mail_address + ","
        file << data.requested_name + ","
        file << data.requested_mail_address + "\n"
      end
      file.close

      filename = 'request_log.csv'
      send_file filename_ws_pass, :filename => filename, :type => "text/csv"

    else
      redirect_to :action => "request_log"
    end
  end

  # 送信情報を表示
  def send_matter_info
    @send_matter = SendMatter.find(:first,
            :conditions => { :id => params['id'] })
    @receivers = Receiver.find(:all,
            :conditions => { :send_matter_id => params['id'] })
    sqlstr = "select " +
          "attachments.id as id, " +
          "attachments.created_at as created_at, " +
          "attachments.name as name, " +
          "attachments.size as size, " +
          "attachments.content_type as content_type, " +
          "attachments.virus_check as virus_check, " +
          "file_dl_checks.download_flg as download_flg " +
          "from attachments, file_dl_checks " +
          "where attachments.id = file_dl_checks.attachment_id " +
          "and attachments.send_matter_id = " + params[:id] + " " +
          "order by attachments.id desc"

    @attachments = Attachment.find_by_sql(sqlstr)

    if @send_matter.download_check
      @download_check = transfer_download_check(@send_matter.download_check)
    end

    if @send_matter.password_notice
      @password_notice = transfer_password_notice(@send_matter.password_notice)
    end

    if @send_matter.file_life_period
      @file_life_period = transfer_file_life_period(
              @send_matter.file_life_period)
    end

    if @send_matter.status
      @status = transfer_sattus(@send_matter.status)
    end
  end

  # 受信情報を表示
  def requested_matter_info
    @requested_matter = RequestedMatter.find(:first,
            :conditions => { :id => params['id'] })
    @requested_attachments = RequestedAttachment.find(:all,
            :conditions => { :requested_matter_id => @requested_matter.id })

    if @requested_matter.download_check
      @download_check = transfer_download_check(
              @requested_matter.download_check)
    end

    if @requested_matter.password_notice
      @password_notice = transfer_password_notice(
              @requested_matter.password_notice)
    end

    if @requested_matter.file_life_period
      @file_life_period = transfer_file_life_period(
              @requested_matter.file_life_period)
    end

    if @requested_matter.status
      @status = transfer_sattus(@requested_matter.status)
    end
  end

  private

  def transfer_download_check(value)
    if value == 0
      return "希望しない"
    elsif value == 1
      return "希望する"
    else
      return ""
    end
  end

  def transfer_password_notice(value)
    if value == 0
      return "自分で通知する"
    elsif value == 1
      return "システムで行う"
    else
      return ""
    end
  end

  def transfer_file_life_period(value)
    file_life_period = ""
    bf_file_life_period = value.to_i
    if bf_file_life_period >= 60 * 60 * 24
      file_life_period = ((bf_file_life_period - bf_file_life_period %
              (60 * 60 * 24)) / (60 * 60 * 24)).to_s + "日"
      bf_file_life_period = bf_file_life_period % (60 * 60 * 24)
    end

    if bf_file_life_period >= 60 * 60
      file_life_period = file_life_period + ((bf_file_life_period -
              bf_file_life_period % (60 * 60)) / (60 * 60)).to_s +
                         "時間"
      bf_file_life_period = bf_file_life_period % (60 * 60)
    end

    if bf_file_life_period >= 60
      file_life_period = file_life_period + ((bf_file_life_period -
              bf_file_life_period % 60) / 60).to_s + "分"
      bf_file_life_period = bf_file_life_period % (60 * 60)
    end

    if bf_file_life_period > 0
      file_life_period = file_life_period + bf_file_life_period.to_s + "秒"
    end
    file_life_period = file_life_period + " (" + value.to_s + ")"
    return file_life_period
  end

  def transfer_sattus(value)
    if value.to_i == 0
      return "無効（ファイル削除済み）"
    elsif value.to_i == 1
      return "有効（ファイル有り）"
    else
      return ""
    end
  end
end
