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
class SysTotalController < ApplicationController
  layout 'system_admin'
  before_action :check_ip_for_administrator, :administrator_authorize

  def index
    session[:section_title] = '実績集計'

    if params[:id]
      if 1 <= params[:id].to_i && params[:id].to_i <= 12
        data_no = params[:id]
      else
        data_no = 1
      end
    else
      data_no = 1
    end

    @c_time = Time.now

    @this_month = @c_time.months_ago(data_no.to_i - 1)
    @next_month = @c_time.months_ago(data_no.to_i - 2)

    s_time = Time.mktime @this_month.year, @this_month.month, 1
    e_time = Time.mktime @next_month.year, @next_month.month, 1

=begin
    sqlstr = "SELECT " +
            "COUNT(id) AS amnt " +
            "FROM send_matters " +
            "WHERE '" + (s_time.strftime("%Y/%m/%d %H:%M:%S")).to_s +
            "' <= created_at " + 
            "AND created_at < '" +
            (e_time.strftime("%Y/%m/%d %H:%M:%S")).to_s + "'"

    @send_matters = SendMatter.find_by_sql(sqlstr)
=end

#=begin
    @send_matters =
      SendMatter
      .select(["COUNT(id) AS amnt",
               ].join(", "))
      .where(:created_at => s_time..s_time.at_end_of_month)

    @send_matter = @send_matters[0].amnt
#=end

=begin
    sqlstr = "SELECT " +
            "COUNT(id) AS amnt, " +
            "SUM(size) AS size " +
            "FROM attachments " +
            "WHERE '" + (s_time.strftime("%Y/%m/%d %H:%M:%S")).to_s +
            "' <= created_at " + 
            "AND created_at < '" +
            (e_time.strftime("%Y/%m/%d %H:%M:%S")).to_s + "'"

    @attachments = Attachment.find_by_sql(sqlstr)
=end

#=begin
    @attachments =
      Attachment
      .select(["COUNT(id) AS amnt",
               "SUM(size) AS size",
               ].join(", "))
      .where(:created_at => s_time..s_time.at_end_of_month)
#=end

    @file_total = @attachments[0].amnt
    @file_size = @attachments[0].size.to_i / (1024 * 1024)

=begin
    sqlstr1 = "SELECT " +
            "COUNT(file_dl_logs.id) AS amnt, " +
            "SUM(attachments.size) AS size " +
            "FROM file_dl_logs, file_dl_checks, attachments " +
            "WHERE file_dl_checks.id = file_dl_logs.file_dl_check_id " +
            "AND file_dl_checks.attachment_id = attachments.id " +
            "AND '" + (s_time.strftime("%Y/%m/%d %H:%M:%S")).to_s +
                 "' <= file_dl_checks.created_at " + 
            "AND file_dl_checks.created_at < '" +
            (e_time.strftime("%Y/%m/%d %H:%M:%S")).to_s + "'"

    sqlstr2 = "SELECT " +
            "COUNT(requested_file_dl_logs.id) AS amnt, " +
            "SUM(requested_attachments.size) AS size " +
            "FROM requested_file_dl_logs, requested_attachments " +
            "WHERE requested_file_dl_logs.requested_attachment_id = " +
            "requested_attachments.id " +
            "AND '" + (s_time.strftime("%Y/%m/%d %H:%M:%S")).to_s +
                 "' <= requested_file_dl_logs.created_at " + 
            "AND requested_file_dl_logs.created_at < '" +
            (e_time.strftime("%Y/%m/%d %H:%M:%S")).to_s + "'"


    @download = FileDlLog.find_by_sql(sqlstr1)
    @download_request = RequestedFileDlLog.find_by_sql(sqlstr2)
=end

#=begin
    @download =
      FileDlCheck
      .select(["COUNT(file_dl_logs.id) AS amnt",
               "SUM(attachments.size) AS size",
               ].join(", "))
      .joins(:file_dl_logs, :attachment)
      .where(:created_at => s_time..s_time.at_end_of_month,
             :download_flg => 1)

    @download_request =
      RequestedAttachment
      .select(["COUNT(requested_file_dl_logs.id) AS amnt",
               "SUM(requested_attachments.size) AS size",
               ].join(", "))
      .joins(:requested_file_dl_logs)
      .where(:created_at => s_time..s_time.at_end_of_month,
             :download_flg => 1)

    @download_file_total = @download[0].amnt.to_i +
            @download_request[0].amnt.to_i
    @download_file_size = (@download[0].size.to_i +
            @download_request[0].size.to_i) / (1024 * 1024)
#=end

=begin
    sqlstr = "SELECT " +
            "COUNT(id) AS amnt " +
            "FROM request_matters " +
            "WHERE '" + (s_time.strftime("%Y/%m/%d %H:%M:%S")).to_s +
            "' <= created_at " + 
            "AND created_at < '" +
            (e_time.strftime("%Y/%m/%d %H:%M:%S")).to_s + "'"

    @request_matters = RequestMatter.find_by_sql(sqlstr)
=end
#=begin
    @request_matters =
      RequestMatter
      .select(["COUNT(id) AS amnt",
               ].join(", "))
      .where(:created_at => s_time..s_time.at_end_of_month)
#=end

    @request_matter = @request_matters[0].amnt
  end
end
