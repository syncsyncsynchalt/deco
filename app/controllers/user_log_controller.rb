# -*- coding: utf-8 -*-
class UserLogController < ApplicationController
  layout 'user_management'
  before_action :authorize, :load_env

  def index
  end

  def index_result
    @conditions = params[:conditions]
    @user_logs = SendMatter.search_q(current_user.id, @conditions).page(params[:page]).per(10)
  end

  def index_request
  end

  def index_request_result
    @conditions = params[:conditions]
    @user_logs = RequestMatter.search_q(current_user.id, @conditions).page(params[:page]).per(10)
  end

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
