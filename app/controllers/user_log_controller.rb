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
class UserLogController < ApplicationController
  layout 'user_management'
  before_action :authorize, :load_env

  def index
    params[:conditions] ||= Hash.new
    @conditions = params[:conditions]
    select_strs = Array.new
    order_values = Array.new
    order_value = Array.new

    where_strs = Array.new
    where_vals = Hash.new

    where_strs << "user_id = :user_id"
    where_vals[:user_id] = current_user.id

    if params[:conditions][:search_text].present?
      case params[:conditions][:search_select]
      when 'name', 'mail_address'
        where_strs << "receivers.#{params[:conditions][:search_select]} LIKE :where_val"
        where_vals[:where_val] = "%#{ActiveRecord::Base.send(:sanitize_sql_like, params[:conditions][:search_text])}%"
      else
      end
    end

    case params[:conditions][:sort_select_1]
    when 'created_at'
      order_value << params[:conditions][:sort_select_1]
    else
      order_value << "created_at"
    end
    params[:conditions][:sort_select_1] ||= 'created_at'
    case params[:conditions][:sort_select_2]
    when 'ASC', 'DESC', 'asc', 'desc'
      order_value << t("views.sort_value.#{params[:conditions][:sort_select_2]}")
    else
      order_value << "desc"
    end
    params[:conditions][:sort_select_2] ||= 'desc'
    order_values << order_value.join(" ")

    @user_logs = 
      SendMatter
      .joins(:receivers)
      .order(order_values.join(", "))
      .page(params[:page])
      .per(10)
    if params[:conditions][:begin_date].present? && params[:conditions][:end_date].present?
      @user_logs =
        @user_logs
        .where(where_strs.join(" AND "), where_vals)
        .where(created_at: Date.parse(params[:conditions][:begin_date]).to_datetime.beginning_of_day.to_s(:db)..Date.parse(params[:conditions][:end_date]).to_datetime.end_of_day.to_s(:db))
    else
      if params[:conditions][:begin_date].present?
        where_strs << "send_matters.created_at >= :created_at_begin"
        where_vals[:created_at_begin] = ActiveRecord::Base.send(:sanitize_sql_like, Date.parse(params[:conditions][:begin_date]).to_datetime.beginning_of_day.to_s(:db))
      elsif params[:conditions][:end_date].present?
        where_strs << "send_matters.created_at <= :created_at_end"
        where_vals[:created_at_end] = ActiveRecord::Base.send(:sanitize_sql_like, Date.parse(params[:conditions][:end_date]).to_datetime.end_of_day.to_s(:db))
#        @user_logs =
#          @user_logs
#          .where(created_at: Float::MIN..Date.parse(params[:conditions][:end_date]).to_datetime.end_of_day.to_s(:db))
      end
      @user_logs =
        @user_logs
        .where(where_strs.join(" AND "), where_vals)
    end
  end

#  def index_result
#    @conditions = params[:conditions]
#    @user_logs = SendMatter.search_q(current_user.id, @conditions).page(params[:page]).per(10)
#  end

  def index_request
    params[:conditions] ||= Hash.new
    @conditions = params[:conditions]
    select_strs = Array.new
    order_values = Array.new
    order_value = Array.new

    where_strs = Array.new
    where_vals = Hash.new

    where_strs << "user_id = :user_id"
    where_vals[:user_id] = current_user.id

    if params[:conditions][:search_text].present?
      case params[:conditions][:search_select]
      when 'name', 'mail_address'
        where_strs << "requested_matters.#{params[:conditions][:search_select]} LIKE :where_val"
        where_vals[:where_val] = "%#{ActiveRecord::Base.send(:sanitize_sql_like, params[:conditions][:search_text])}%"
      else
      end
    end

    case params[:conditions][:sort_select_1]
    when 'created_at'
      order_value << params[:conditions][:sort_select_1]
    else
      order_value << "created_at"
    end
    params[:conditions][:sort_select_1] ||= 'created_at'
    case params[:conditions][:sort_select_2]
    when 'ASC', 'DESC', 'asc', 'desc'
      order_value << t("views.sort_value.#{params[:conditions][:sort_select_2]}")
    else
      order_value << "desc"
    end
    params[:conditions][:sort_select_2] ||= 'desc'
    order_values << order_value.join(" ")

    @user_logs = 
      RequestMatter
      .joins(:requested_matters)
      .order(order_values.join(", "))
      .page(params[:page])
      .per(10)
    if params[:conditions][:begin_date].present? && params[:conditions][:end_date].present?
      @user_logs =
        @user_logs
        .where(where_strs.join(" AND "), where_vals)
        .where(created_at: Date.parse(params[:conditions][:begin_date]).to_datetime.beginning_of_day.to_s(:db)..Date.parse(params[:conditions][:end_date]).to_datetime.end_of_day.to_s(:db))
    else
      if params[:conditions][:begin_date].present?
        where_strs << "request_matters.created_at >= :created_at_begin"
        where_vals[:created_at_begin] = ActiveRecord::Base.send(:sanitize_sql_like, Date.parse(params[:conditions][:begin_date]).to_datetime.beginning_of_day.to_s(:db))
      elsif params[:conditions][:end_date].present?
        where_strs << "request_matters.created_at <= :created_at_end"
        where_vals[:created_at_end] = ActiveRecord::Base.send(:sanitize_sql_like, Date.parse(params[:conditions][:end_date]).to_datetime.end_of_day.to_s(:db))
      end
      @user_logs =
        @user_logs
        .where(where_strs.join(" AND "), where_vals)
    end
#    @user_logs = RequestMatter.search_q(current_user.id, @conditions).page(params[:page]).per(10)
  end

#  def index_request_result
#    @conditions = params[:conditions]
#    @user_logs = RequestMatter.search_q(current_user.id, @conditions).page(params[:page]).per(10)
#  end

  # 送信情報を表示
  def send_matter_info
    @send_matter =
        SendMatter
        .where(:id => params['id'])
        .first
    @permit_flg = 0
    if @send_matter.present?
      if @send_matter.user_id.present? &&
          @send_matter.user_id.to_i == current_user.id
        @permit_flg = 1
      end
    end
    if @permit_flg == 1
      @receivers =
          Receiver
          .where(:send_matter_id => params['id'])
=begin
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
=end
#=begin
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
#=end

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
    else
      redirect_to :action => :index
    end
  end

  def requested_matter_info
    @requested_matter =
        RequestedMatter
        .where(:id => params['id'])
        .first
    @permit_flg = 0
    if @requested_matter.present? && @requested_matter.request_matter.present?
      @request_matter = @requested_matter.request_matter
      if @request_matter.user_id.present? &&
          @request_matter.user_id.to_i == current_user.id
        @permit_flg = 1
      end
    end
    if @permit_flg == 1
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
    else
      redirect_to :action => :index_request
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
