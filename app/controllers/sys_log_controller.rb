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
  before_action :check_ip_for_administrator, :administrator_authorize
  before_action :load_env
  $database = ""

  MAPPINGS = {
    "\u{00A2}" => "\u{FFE0}",
    "\u{00A3}" => "\u{FFE1}",
    "\u{00AC}" => "\u{FFE2}",
    "\u{2016}" => "\u{2225}",
    "\u{2012}" => "\u{FF0D}",
    "\u{301C}" => "\u{FF5E}"
  }

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

    if params[:type]
      @type = params[:type]
    end

    if params[:keyward]
      @keyward = params[:keyward]
    end

    @select_month = Array.new
    @select_month.push ["選んで下さい", 0]
    @rs =
      SendMatter
      .select(["DISTINCT DATE_FORMAT(created_at, \'%Y%m\') AS m",
               ].join(", "))
      .order(["DATE_FORMAT(created_at, \'%Y%m\') DESC",
              ].join(", "))
    @rs.each do | data |
      year = data.m.slice(0, 4).to_i
      mon = data.m.slice(4, 2).to_i
      @select_month.push [year.to_s + '年' + mon.to_s + '月', data.m]
    end

    if params[:keyward]
      case @type.to_i
      when 1
        column = "send_matters.name"
      when 2
        column = "send_matters.mail_address"
      when 3
        column = "receivers.name"
      when 4
        column = "receivers.mail_address"
      end
    end

    @rs =
      SendMatter
      .select(["send_matters.id AS send_matter_id",
               "send_matters.created_at AS created_at",
               "send_matters.name AS sender_name",
               "send_matters.mail_address AS sender_mail_address",
               "COUNT(attachments.id) AS total_file",
               "SUM(attachments.size) AS total_size",
               "1 AS data_order",
               ].join(", "))
      .left_joins(:receivers,
             :attachments)
      .order(["send_matters.created_at DESC",
              ].join(", "))
      .group(["send_matters.id",
              "send_matters.created_at",
              "send_matters.name",
              "send_matters.mail_address",
              ].join(", "))
    if params[:keyward].present? && @type.to_i >= 1 && @type.to_i <= 4
      @rs =
        @rs.where([["#{column} LIKE :keyward",
                 ].join(" AND "),
                keyward: "%#{ActiveRecord::Base.send(:sanitize_sql_like, @keyward)}%",
                ])
    end

    @total_data = @rs.length
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

    @rs =
      @rs
      .offset(@s_data - 1)
      .limit(@amt_data)

    @time2 = Time.now.strftime("%Y/%m/%d %H:%M:%S")
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
        send_column = "receivers.name"
        request_column = "request_matters.name"
      when 1
        send_column = "receivers.mail_address"
        request_column = "request_matters.mail_address"
      end
    end

    @select_month = Array.new
    @select_month.push ["選んで下さい", 0]
    @rs =
      FileDlLog
      .select(["DISTINCT DATE_FORMAT(created_at, \'%Y%m\') AS m",
               ].join(", "))
      .union(RequestedFileDlLog
      .select(["DISTINCT DATE_FORMAT(created_at, \'%Y%m\') AS m",
               ].join(", ")))
      .order(["m DESC",
              ].join(", "))
    @rs.each do | data |
      year = data.m.slice(0, 4).to_i
      mon = data.m.slice(4, 2).to_i
      @select_month.push [year.to_s + '年' + mon.to_s + '月', data.m]
    end

    send_dl_logs =
      FileDlCheck
      .select(["file_dl_logs.created_at AS dl_at",
               "'送信' AS flg",
               "receivers.name AS receiver_name",
               "receivers.mail_address AS receiver_mail_address",
               "attachments.name AS file_name",
               "attachments.size AS file_size",
               ].join(", "))
      .joins(:file_dl_logs, :attachment, :receiver)
      .where(:download_flg => 1)
    if params[:keyward].present? && @type.to_i >= 0 && @type.to_i <= 1
      send_dl_logs =
        send_dl_logs
        .where([["#{send_column} LIKE :keyward",
                 ].join(" AND "),
                keyward: "%#{ActiveRecord::Base.send(:sanitize_sql_like, @keyward)}%",
                ])
    end

    request_dl_logs =
      RequestedAttachment
      .select(["requested_file_dl_logs.created_at AS dl_at",
               "'依頼' AS flg",
               "request_matters.name AS receiver_name",
               "request_matters.mail_address AS receiver_mail_address",
               "requested_attachments.name AS file_name",
               "requested_attachments.size AS file_size",
               ].join(", "))
      .joins(:requested_file_dl_logs, requested_matter: :request_matter)
      .where(:download_flg => 1)

    if params[:keyward].present? && @type.to_i >= 0 && @type.to_i <= 1
      request_dl_logs =
        request_dl_logs
        .where([["#{request_column} LIKE :keyward",
                 ].join(" AND "),
                keyward: "%#{ActiveRecord::Base.send(:sanitize_sql_like, @keyward)}%",
                ])
    end

    @rs =
      send_dl_logs
      .union(request_dl_logs)
      .order(["dl_at DESC",
              ].join(", "))

    if params[:id]
      @page = params[:id].to_i
    else
      @page = 1
    end

    if @page <= 0
      @page = 1
    end

    @amt_data = 100

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
        condition = " AND " + condition + " "
      end

      case @type.to_i
      when 0
        column = "request_matters.name"
      when 1
        column = "request_matters.mail_address"
      when 2
        column = "requested_matters.name"
      when 3
        column = "requested_matters.mail_address"
      end
      if @type.to_i >= 0 && @type.to_i <= 3
        @rs = 
          RequestMatter
          .select(["DISTINCT(request_matters.id)",
                   ].join(", "))
          .where([["#{column} LIKE :keyward",
                   ].join(" AND "),
                  keyward: "%#{ActiveRecord::Base.send(:sanitize_sql_like, @keyward)}%",
                  ])
        if @type.to_i >= 2 && @type.to_i <= 3
          @rs =
            @rs.joins(:requested_matters)
        end
      else
        @rs = RequestMatter.all
      end
      @total_data = @rs.length
    else
      @rs = RequestMatter.all
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
    @rs =
      RequestMatter
      .select(["DISTINCT DATE_FORMAT(created_at, \'%Y%m\') AS m",
               ].join(", "))
      .order(["DATE_FORMAT(created_at, \'%Y%m\') DESC",
              ].join(", "))
    @rs.each do | data |
      year = data.m.slice(0, 4).to_i
      mon = data.m.slice(4, 2).to_i
      @select_month.push [year.to_s + '年' + mon.to_s + '月', data.m]
    end

    @part_of_page = original_paginate('sys_log', 'request_log', @page,
            @total_page, 4, 2)

    @rs =
      RequestMatter
      .select(["request_matters.id AS request_matter_id",
               "request_matters.name AS request_name",
               "request_matters.mail_address AS request_mail_address",
               "request_matters.created_at AS created_at",
               "requested_matters.id AS requested_matter_id",
               "requested_matters.name AS requested_name",
               "requested_matters.mail_address AS requested_mail_address",
               ].join(", "))
      .joins(:requested_matters)
      .order(["request_matters.created_at DESC",
              ].join(", "))
    if params[:keyward].present? && @type.to_i >= 0 && @type.to_i <= 3
      @rs =
        @rs.where([["#{column} LIKE :keyward",
                 ].join(" AND "),
                keyward: "%#{ActiveRecord::Base.send(:sanitize_sql_like, @keyward)}%",
                ])
    end
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
      if year >= 1 && year <= 9999 && mon >=1 && mon <= 12
        time = Time.mktime year, mon
        if condition == ""
          condition = "WHERE "
        else
          condition = condition + "AND "
        end
        condition = condition + "created_at BETWEEN '" + (time.strftime("%Y-%m-%d %H:%M:%S")) + "'" +
                "AND '" + (time.at_end_of_month.strftime("%Y-%m-%d %H:%M:%S")) + "' "
      else
        rslt = 1
      end
    end

    deletefiles = Dir.glob(@params_app_env['FILE_DIR'] + '/log_send_' + '*')
    deletefiles.each do |deletefile|
      File.delete(deletefile)
    end

    if rslt == 0
=begin
      sqlstr = "SELECT " +
            "tbl1.sub_id AS send_matter_id, " +
            "tbl1.created_at AS created_at, " +
            "tbl1.sender_name AS sender_name, " +
            "tbl1.mail_address AS sender_mail_address, " +
            "receivers.name AS receiver_name, " +
            "receivers.mail_address AS receiver_mail_address, " +
            "tbl1.total_file AS total_file, " +
            "tbl1.total_size AS total_size, " +
            "tbl1.data_order AS data_order " +
            "FROM " +
              "(SELECT " + 
              "tbl2.id AS sub_id, " +
              "tbl2.created_at AS created_at, " +
              "tbl2.name AS sender_name, " +
              "tbl2.mail_address AS mail_address, " +
              "tbl2.data_order AS data_order, " +
              "COUNT(attachments.id) AS total_file, " +
              "SUM(attachments.size) AS total_size " +
              "FROM " +
                "(SELECT " +
                "id, created_at, name, mail_address, 1 AS data_order " +
                "FROM send_matters " + condition +
                "ORDER BY created_at DESC " +
                ") AS tbl2 " +
              "LEFT OUTER JOIN attachments " +
              "ON tbl2.id = attachments.send_matter_id " +
              "GROUP BY " +
              "tbl2.id, tbl2.created_at, sender_name, mail_address, data_order" +
              ") AS tbl1 " +
            "LEFT OUTER JOIN receivers " +
            "ON tbl1.sub_id = receivers.send_matter_id " +
            "ORDER BY tbl1.created_at DESC"

      @rs = RequestMatter.find_by_sql(sqlstr)
=end
#=begin
        @rs =
          SendMatter
          .select(["send_matters.id AS send_matter_id",
                   "send_matters.created_at AS created_at",
                   "send_matters.name AS sender_name",
                   "send_matters.mail_address AS sender_mail_address",
                   "receivers.name AS receiver_name",
                   "receivers.mail_address AS receiver_mail_address",
                   "COUNT(attachments.id) AS total_file",
                   "SUM(attachments.size) AS total_size",
                   "1 AS data_order",
                   ].join(", "))
          .joins(receivers: :attachments)
          .where(created_at: time..time.at_end_of_month)
          .group(["send_matters.id",
                  "receivers.id",
                  ].join(", "))
          .order(["send_matters.created_at DESC",
                  "receivers.id DESC",
                  ].join(", "))
#=end

      filename = 'log_send_' + Time.now.strftime("%Y-%m-%d_%H:%M:%S")
      filename_ws_pass = @params_app_env['FILE_DIR'] + '/' + filename
      filename_ws_pass = filename_ws_pass
      file = open(filename_ws_pass, 'w:CP932')
      file << '登録日,送信ＩＤ,送信者名,送信者メールアドレス,'
      file << '受信者名,受信者メールアドレス,総ファイル数,総ファイルサイズ' + "\n"

      @rs.each do | data |
        str = ''
        str += (Time.parse(data.created_at.to_s)).
                strftime("%Y/%m/%d %H:%M:%S") + ","
        str += data.send_matter_id.to_s + ","
        str += data.sender_name + ","
        str += data.sender_mail_address + ","
        if data.receiver_name
          str += data.receiver_name
        end
        str += ","
        if data.receiver_mail_address
          str += data.receiver_mail_address
        end
        str += ","
        str += data.total_file.to_s + ","
        str += data.total_size.to_s + "\n"
#        str.encode(Encoding::Windows_31J, undef: :replace).encode(Encoding::UTF_8)
        MAPPINGS.each{|before, after| str = str.gsub(before, after) }
        file << str.encode(Encoding::Windows_31J, undef: :replace)
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
      if year >= 1 && year <= 9999 && mon >=1 && mon <= 12
        time = Time.mktime year, mon
        condition_day1 = "WHERE file_dl_logs.created_at BETWEEN '" + (time.strftime("%Y-%m-%d")) + "'" +
                "AND '" + (time.at_end_of_month.strftime("%Y-%m-%d")) + "' "
        condition2 = condition2 + " AND requested_file_dl_logs.created_at BETWEEN \'" + (time.strftime("%Y-%m-%d")) + "\'" +
                "AND '" + (time.at_end_of_month.strftime("%Y-%m-%d")) + "' "
      else
        rslt = 1
      end
    end

    deletefiles = Dir.glob(@params_app_env['FILE_DIR'] + '/log_receive_' + '*')
    deletefiles.each do |deletefile|
      File.delete(deletefile)
    end

    if rslt == 0
=begin
      sqlstr_sub1 = "SELECT " +
              "tbl1.dl_at AS dl_at, " +
              "'送信' AS flg, " +
              "receivers.name AS receiver_name, " +
              "receivers.mail_address AS receiver_mail_address, " +
              "attachments.name AS file_name, " +
              "attachments.size AS file_size " +
              "FROM attachments, receivers, send_matters, " +
                "(SELECT " +
                "file_dl_checks.id AS id, " +
                "file_dl_logs.created_at AS dl_at, " +
                "file_dl_checks.receiver_id AS receiver_id, " +
                "file_dl_checks.attachment_id AS attachment_id " +
                "FROM file_dl_logs " +
                "LEFT OUTER JOIN file_dl_checks " +
                "ON file_dl_logs.file_dl_check_id = file_dl_checks.id " +
                condition_day1 + ") AS tbl1 " +
              "WHERE attachments.id = tbl1.attachment_id " +
              "AND receivers.id = tbl1.receiver_id " +
              "AND send_matters.id = attachments.send_matter_id" +
              condition1

      sqlstr_sub2 = "SELECT " +
              "requested_file_dl_logs.created_at AS dl_at, " +
              "'依頼' AS flg, " +
              "request_matters.name AS receiver_name, " +
              "request_matters.mail_address AS receiver_mail_address, " +
              "requested_attachments.name AS file_name, " +
              "requested_attachments.size AS file_size " +
              "FROM request_matters, requested_matters, " +
              " requested_file_dl_logs, requested_attachments " +
              "WHERE requested_file_dl_logs.requested_attachment_id = " +
              "requested_attachments.id " +
              "AND requested_attachments.requested_matter_id = " +
              "requested_matters.id " +
              "AND requested_matters.request_matter_id = request_matters.id" +
              condition2

      sqlstr = sqlstr_sub1 + " UNION ALL " + sqlstr_sub2 + " ORDER BY dl_at DESC"
      @rs = RequestMatter.find_by_sql(sqlstr)
=end
#=begin
      send_dl_logs =
        FileDlCheck
        .select(["file_dl_logs.created_at AS dl_at",
                 "'送信' AS flg",
                 "receivers.name AS receiver_name",
                 "receivers.mail_address AS receiver_mail_address",
                 "attachments.name AS file_name",
                 "attachments.size AS file_size",
                 ].join(", "))
        .joins(:file_dl_logs, :attachment, :receiver)
        .where(created_at: time..time.at_end_of_month,
               :download_flg => 1)
      request_dl_logs =
        RequestedAttachment
        .select(["requested_file_dl_logs.created_at AS dl_at",
                 "'依頼' AS flg",
                 "request_matters.name AS receiver_name",
                 "request_matters.mail_address AS receiver_mail_address",
                 "requested_attachments.name AS file_name",
                 "requested_attachments.size AS file_size",
                 ].join(", "))
        .joins(:requested_file_dl_logs, requested_matter: :request_matter)
        .where(created_at: time..time.at_end_of_month,
               :download_flg => 1)
      @rs =
        send_dl_logs
        .union(request_dl_logs)
        .order(["dl_at DESC",
                ].join(", "))
#=end

      filename = 'log_receive_' + Time.now.strftime("%Y-%m-%d_%H:%M:%S")
      filename_ws_pass = @params_app_env['FILE_DIR'] + '/' + filename
      file = open(filename_ws_pass, 'w:CP932')
      file << 'ダウンロード日,区分,受信者,受信者メールアドレス,'
      file << 'ファイル名,ファイルサイズ' + "\n"

      @rs.each do | data |
=begin
        file << (Time.parse(data.dl_at.to_s)).
                strftime("%Y/%m/%d %H:%M:%S") + ","
        file << data.flg + ","
        file << data.receiver_name + ","
        file << data.receiver_mail_address + ","
        file << data.file_name + ","
        file << data.file_size.to_s + "\n"
=end
        str = ''
        str += (Time.parse(data.dl_at.to_s)).
                strftime("%Y/%m/%d %H:%M:%S") + ","
        str += data.flg.to_s + ","
        str += data.receiver_name.to_s + ","
        str += data.receiver_mail_address.to_s + ","
        str += data.file_name.to_s + ","
        str += data.file_size.to_s + "\n"
#        str.encode(Encoding::Windows_31J, undef: :replace).encode(Encoding::UTF_8)
        MAPPINGS.each{|before, after| str = str.gsub(before, after) }
        file << str.encode(Encoding::Windows_31J, undef: :replace)
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
      if year >= 1 && year <= 9999 && mon >=1 && mon <= 12
        time = Time.mktime year, mon
        if condition == ""
          condition = "WHERE "
        else
          condition = condition + "AND "
        end
        condition = condition + "request_matters.created_at BETWEEN '" + (time.strftime("%Y-%m-%d")) + "' " +
                "AND '" + (time.at_end_of_month.strftime("%Y-%m-%d")) + "' "
      else
        rslt = 1
      end
    end

    # 不要ログの削除
    deletefiles = Dir.glob(@params_app_env['FILE_DIR'] + '/log_request_' + '*')
    deletefiles.each do |deletefile|
      File.delete(deletefile)
    end

    if rslt == 0
=begin
      sqlstr = "SELECT " +
              "request_matters.id AS request_matter_id, " +
              "request_matters.name AS request_name, " +
              "request_matters.mail_address AS request_mail_address, " +
              "request_matters.created_at AS created_at, " +
              "requested_matters.id AS requested_matter_id, " +
              "requested_matters.name AS requested_name, " +
              "requested_matters.mail_address AS requested_mail_address " +
              "FROM request_matters " +
              "LEFT OUTER JOIN requested_matters ON request_matters.id = " +
              "requested_matters.request_matter_id " +
              condition +
              "ORDER BY request_matters.created_at DESC"

      @rs = RequestMatter.find_by_sql(sqlstr)
=end

#=begin
      @rs =
        RequestMatter
        .select(["request_matters.id AS request_matter_id",
                 "request_matters.name AS request_name",
                 "request_matters.mail_address AS request_mail_address",
                 "request_matters.created_at AS created_at",
                 "requested_matters.id AS requested_matter_id",
                 "requested_matters.name AS requested_name",
                 "requested_matters.name AS requested_name",
                 "requested_matters.mail_address AS requested_mail_address",
                 ].join(", "))
        .joins(:requested_matters)
        .where(created_at: time..time.at_end_of_month)
        .order(["request_matters.created_at DESC",
                "requested_matters.id DESC",
                ].join(", "))
#=end

      filename = 'log_request_' + Time.now.strftime("%Y-%m-%d_%H:%M:%S")
      filename_ws_pass = @params_app_env['FILE_DIR'] + '/' + filename
      file = open(filename_ws_pass, 'w:CP932')
      file << '登録日,依頼ＩＤ,依頼人,依頼人メールアドレス,'
      file << '送信者名,送信者メールアドレス' + "\n"

      @rs.each do | data |
=begin
        file << (Time.parse(data.created_at.to_s)).
                strftime("%Y/%m/%d %H:%M:%S") + ","
        file << data.request_matter_id.to_s + ","
        file << data.request_name + ","
        file << data.request_mail_address + ","
        file << data.requested_name + ","
        file << data.requested_mail_address + "\n"
=end
        str = ''
        str += (Time.parse(data.created_at.to_s)).
                strftime("%Y/%m/%d %H:%M:%S") + ","
        str += data.request_matter_id.to_s + ","
        str += data.request_name.to_s + ","
        str += data.request_mail_address.to_s + ","
        str += data.requested_name.to_s + ","
        str += data.requested_mail_address.to_s + "\n"
#        str.encode(Encoding::Windows_31J, undef: :replace).encode(Encoding::UTF_8)
        MAPPINGS.each{|before, after| str = str.gsub(before, after) }
        file << str.encode(Encoding::Windows_31J, undef: :replace)
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
    @send_matter =
        SendMatter
        .where(:id => params['id'])
        .first
    @receivers =
        Receiver
        .where(:send_matter_id => params['id'])
=begin
    sqlstr = "SELECT " +
          "attachments.id AS id, " +
          "attachments.created_at AS created_at, " +
          "attachments.name AS name, " +
          "attachments.size AS size, " +
          "attachments.content_type AS content_type, " +
          "attachments.virus_check AS virus_check, " +
          "file_dl_checks.download_flg AS download_flg " +
          "FROM attachments, file_dl_checks " +
          "WHERE attachments.id = file_dl_checks.attachment_id " +
          "AND attachments.send_matter_id = " + params[:id] + " " +
          "ORDER BY attachments.id DESC"

    @attachments = Attachment.find_by_sql(sqlstr)
=end
    @attachments =
      Attachment
      .select(["attachments.id as id",
               "attachments.created_at as created_at",
               "attachments.name as name",
               "attachments.size as size",
               "attachments.content_type as content_type",
               "attachments.virus_check as virus_check",
               "file_dl_checks.download_flg as download_flg",
               ].join(", "))
      .left_joins(:file_dl_checks)
      .where(:send_matter_id => params[:id])
      .order(["attachments.id ASC",
              ].join(", "))

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
    @requested_matter =
        RequestedMatter
        .where(:id => params['id'])
        .first
    @requested_attachments =
        RequestedAttachment
        .where(:requested_matter_id => @requested_matter.id)

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
