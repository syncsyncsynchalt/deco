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
class SysDataController < ApplicationController
  layout 'system_admin'
  before_action :load_env
  before_action :check_ip_for_administrator, :administrator_authorize

  def index
    session[:section_title] = '登録データ確認'
    if params[:id]
      @page = params[:id].to_i
    else
      @page = 1
    end
    if @page <= 0
      @page = 1
    end

    @amt_data = 100
    @s_data = (@page - 1) * @amt_data + 1
    @e_data = @page * @amt_data
    sqlstr_sub1 = "SELECT " +
            "attachments.created_at AS file_up_date, " +
            "send_matters.id AS id, " +
            "'送信' AS flg, " +
            "send_matters.name AS sender_name, " +
            "send_matters.mail_address AS sender_mail_address, " +
            "attachments.id AS file_id, " +
            "attachments.name AS file_name, " +
            "attachments.size AS file_size, " +
            "attachments.content_type AS file_content_type, " +
            "file_dl_checks.download_flg AS file_download_flg, " +
            "attachments.virus_check AS file_virus_check " +
            "FROM file_dl_checks, attachments, send_matters " +
            "WHERE file_dl_checks.attachment_id = attachments.id " +
            "AND attachments.send_matter_id = send_matters.id"
    sqlstr_sub2 = "SELECT " +
            "requested_matters.file_up_date AS file_up_date, " +
            "requested_matters.id AS id, " +
            "'依頼' AS flg, " +
            "requested_matters.name AS sender_name, " +
            "requested_matters.mail_address AS sender_mail_address, " +
            "requested_attachments.id AS file_id, " +
            "requested_attachments.name AS file_name, " +
            "requested_attachments.size AS file_size, " +
            "requested_attachments.content_type AS file_content_type, " +
            "requested_attachments.download_flg AS file_download_flg, " +
            "requested_attachments.virus_check AS file_virus_check " +
            "FROM requested_matters, " +
            " requested_attachments " +
            "WHERE requested_attachments.requested_matter_id = " +
            "requested_matters.id "
    sqlstr = sqlstr_sub1 + " UNION " + sqlstr_sub2 +
          " ORDER BY file_up_date DESC"
    @saved_files = FileDlCheck.find_by_sql(sqlstr)
    @total_page = (@saved_files.length/@amt_data).to_i
    unless @saved_files.length % @amt_data == 0 
      @total_page = @total_page + 1
    end
    @part_of_page = original_paginate('sys_data', 'index', @page,
            @total_page, 4, 2)
  end

  # 送信ファイルのダウンロード
  def get_send_file
    @attachment = Attachment.find(params[:id])

#    if request.user_agent =~ /Windows/i
#      if request.user_agent =~ /Trident/i
#          request.user_agent =~ /MSIE/i
#       @filename = @attachment.name.encode(Encoding::Windows_31J, undef: :replace)
#      else
#        @filename = @attachment.name
#      end
#    elsif request.user_agent =~ /Mac/i
#      @filename = @attachment.name
#    else
#      @filename = @attachment.name
#    end
    @filename = @attachment.name

    if File.exist?(@params_app_env['FILE_DIR'] + "/#{@attachment.id}")
      send_file @params_app_env['FILE_DIR'] + "/#{@attachment.id}",
               :filename => @filename,
               :type => @attachment.content_type,
               :x_sendfile => true
    else
      flash[:error] = @params_app_env['FILE_DIR'] +
             "/#{@attachment.id}　が存在しません"
      render :action => "message"
    end
  end

  # 依頼送信ファイルのダウンロード
  def get_requested_file
    @requested_attachment = RequestedAttachment.find(params[:id])
#    if request.user_agent =~ /Windows/i
#      if request.user_agent =~ /Trident/i
#          request.user_agent =~ /MSIE/i
#        @filename = @requested_attachment.name.encode(Encoding::Windows_31J, undef: :replace#)
#      else
#        @filename = @requested_attachment.name
#      end
#    elsif request.user_agent =~ /Mac/i
#      @filename = @requested_attachment.name
#    else
#      @filename = @requested_attachment.name
#    end
    @filename = @requested_attachment.name

    if File.exist?(@params_app_env['FILE_DIR'] + "/r#{@requested_attachment.id}")
      send_file @params_app_env['FILE_DIR'] + "/r#{@requested_attachment.id}",
               :filename => @filename,
               :type => @requested_attachment.content_type,
               :x_sendfile => true
    else
      flash[:error] = @params_app_env['FILE_DIR'] +
              "/r#{@requested_attachment.id}　が存在しません"
      render :action => "message"
    end
  end

  def message
  end
end
