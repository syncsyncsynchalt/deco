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
  before_filter :check_ip_for_administrator, :administrator_authorize

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

    sqlstr = "select " +
            "count(id) as amnt " +
            "from send_matters " +
            "where '" + (s_time.strftime("%Y/%m/%d %H:%M:%S")).to_s +
            "' <= created_at " + 
            "and created_at < '" +
            (e_time.strftime("%Y/%m/%d %H:%M:%S")).to_s + "'"

    @send_matters = SendMatter.find_by_sql(sqlstr)

    @send_matter = @send_matters[0].amnt

    sqlstr = "select " +
            "count(id) as amnt, " +
            "sum(size) as size " +
            "from attachments " +
            "where '" + (s_time.strftime("%Y/%m/%d %H:%M:%S")).to_s +
            "' <= created_at " + 
            "and created_at < '" +
            (e_time.strftime("%Y/%m/%d %H:%M:%S")).to_s + "'"

    @attachments = Attachment.find_by_sql(sqlstr)

    @file_total = @attachments[0].amnt
    @file_size = @attachments[0].size.to_i / (1024 * 1024)

    sqlstr1 = "select " +
            "count(file_dl_logs.id) as amnt, " +
            "sum(attachments.size) as size " +
            "from file_dl_logs, file_dl_checks, attachments " +
            "where  file_dl_checks.id = file_dl_logs.file_dl_check_id " +
            "and file_dl_checks.attachment_id = attachments.id " +
            "and '" + (s_time.strftime("%Y/%m/%d %H:%M:%S")).to_s +
                 "' <= convert_tz(file_dl_checks.created_at," +
                 " '+00:00', '-9:00') " + 
            "and file_dl_checks.created_at < '" +
            (e_time.strftime("%Y/%m/%d %H:%M:%S")).to_s + "'"

    sqlstr2 = "select " +
            "count(requested_file_dl_logs.id) as amnt, " +
            "sum(requested_attachments.size) as size " +
            "from requested_file_dl_logs, requested_attachments " +
            "where requested_file_dl_logs.requested_attachment_id = " +
            "requested_attachments.id " +
            "and '" + (s_time.strftime("%Y/%m/%d %H:%M:%S")).to_s +
                 "' <= convert_tz(requested_file_dl_logs.created_at, " +
                 "'+00:00', '-9:00') " + 
            "and requested_file_dl_logs.created_at < '" +
            (e_time.strftime("%Y/%m/%d %H:%M:%S")).to_s + "'"


    @download = FileDlLog.find_by_sql(sqlstr1)
    @download_request = RequestedFileDlLog.find_by_sql(sqlstr2)

    @download_file_total = @download[0].amnt.to_i +
            @download_request[0].amnt.to_i
    @download_file_size = (@download[0].size.to_i +
            @download_request[0].size.to_i) / (1024 * 1024)


    sqlstr = "select " +
            "count(id) as amnt " +
            "from request_matters " +
            "where '" + (s_time.strftime("%Y/%m/%d %H:%M:%S")).to_s +
            "' <= created_at " + 
            "and created_at < '" +
            (e_time.strftime("%Y/%m/%d %H:%M:%S")).to_s + "'"

    @request_matters = RequestMatter.find_by_sql(sqlstr)

    @request_matter = @request_matters[0].amnt
  end
end
