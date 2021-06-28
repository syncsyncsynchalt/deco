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
class Notification < ActionMailer::Base
  helper :application
  app_env_from_mail_address =
      AppEnv
      .where(["`key` = 'FROM_MAIL_ADDRESS'",
             "category = 0"].join(" AND "))
      .first
  if app_env_from_mail_address.present?
    default from: app_env_from_mail_address.value
  else
    default from: "from@example.com"
  end

  def send_report(send_matter, receiver, attachments, url)
    @send_matter = send_matter
    @receiver = receiver
    @attachments = attachments
    @url = url
    mail(:to => receiver.mail_address,
         :subject => 'ファイル送信のご連絡',
         :reply_to => send_matter.mail_address)
  end

  def send_password_report(send_matter, receiver, attachments, url)
    @send_matter = send_matter
    @receiver = receiver
    @attachments = attachments
    @url = url
    mail(:to => receiver.mail_address,
         :subject => 'ファイル送信パスワードのご連絡',
         :reply_to => send_matter.mail_address)
  end

  def send_result_report(send_matter, receivers, attachments, url)
    @send_matter = send_matter
    @receivers = receivers
    @attachments = attachments
    @url = url
    mail(:to => send_matter.mail_address,
         :subject => 'ファイル送信のご連絡【控】',
         :reply_to => send_matter.mail_address)
  end

  def receive_report(send_matter, receiver, attachment)
    @send_matter = send_matter
    @receiver = receiver
    @attachment = attachment
    mail(:to => send_matter.mail_address,
         :subject => 'ファイルダウンロードのご連絡',
         :reply_to => receiver.mail_address)
  end

  def file_delete_report(send_matter, receiver, attachment)
    @send_matter = send_matter
    @receiver = receiver
    @attachment = attachment
    mail(:to => receiver.mail_address,
         :subject => 'ファイル削除のご連絡',
         :reply_to => send_matter.mail_address)
  end

  def file_delete_result_report(send_matter, receivers, attachment, url)
    @send_matter = send_matter
    @receivers = receivers
    @attachment = attachment
    @url = url
    mail(:to => send_matter.mail_address,
         :subject => 'ファイル削除のご連絡【控】',
         :reply_to => send_matter.mail_address)
  end

  def request_report(request_matter, mail_receiver, mail_receiver_addr, url, pass, request_period)
    @request_matter = request_matter
    @receiver = mail_receiver
    @url = url
    @pass = pass
    @request_period = request_period
    mail(:to => mail_receiver_addr,
         :subject => 'ファイル送信依頼のご連絡',
         :reply_to => request_matter.mail_address)
  end

  def request_password_report(request_matter, mail_receiver, mail_receiver_addr, url, pass, request_period)
    @request_matter = request_matter
    @receiver = mail_receiver
    @url = url
    @pass = pass
    @request_period = request_period
    mail(:to => mail_receiver_addr,
         :subject => 'ファイル送信依頼パスワードのご連絡',
         :reply_to => request_matter.mail_address)
  end

  def request_copied_report(request_matter, requested_matters, url, request_period, sent_at = Time.now)
    @request_matter = request_matter
    @requested_matters = requested_matters
    @url = url
    @request_period = request_period
    mail(:to => request_matter.mail_address,
         :subject => 'ファイル送信依頼のご連絡【控】',
         :reply_to => request_matter.mail_address)
  end

  def requested_send_report(requested_matter, attachments, url)
    @requested_matter = requested_matter
    @attachments = attachments
    @url = url

    mail(:to => requested_matter.request_matter.mail_address,
         :subject => 'ファイル送信のご連絡(依頼)',
         :reply_to => requested_matter.mail_address)
  end

  def requested_send_password_report(requested_matter, attachments, url)
    @requested_matter = requested_matter
    @attachments = attachments
    @url = url

    mail(:to => requested_matter.request_matter.mail_address,
         :subject => 'ファイル送信パスワードのご連絡(依頼)',
         :reply_to => requested_matter.mail_address)
  end

  def requested_send_copied_report(requested_matter, attachments, url, url2, password_automation)
    @requested_matter = requested_matter
    @attachments = attachments
    @url = url
    @url2 = url2
    @password_automation = password_automation

    mail(:to => requested_matter.mail_address,
         :subject => 'ファイル送信のご連絡(依頼)【控】',
         :reply_to => requested_matter.mail_address)
  end

  def requested_file_delete_report(requested_matter, attachment)
    @name = requested_matter.request_matter.name
    @sender = requested_matter.name
    @attachment = attachment
    mail(:to => requested_matter.mail_address,
         :subject => 'ファイル削除のご連絡',
         :reply_to => requested_matter.mail_address)
  end

  def requested_file_delete_copied_report(requested_matter, attachment, url)
    @requested_matter = requested_matter
    @attachment = attachment
    @url = url
    mail(:to => requested_matter.mail_address,
         :subject => 'ファイル削除のご連絡【控】',
         :reply_to => requested_matter.mail_address)
  end

  def requested_file_dl_report(requested_attachment)
    @requested_matter = requested_attachment.requested_matter
    @attachment = requested_attachment
    mail(:to => requested_attachment.requested_matter.mail_address,
         :subject => 'ファイルダウンロード完了のご連絡',
         :reply_to => requested_attachment.requested_matter.request_matter.mail_address)
  end

  def send_virus_info_report(send_matter, virus_attachments, receivers, user)
    @send_matter = send_matter
    @virus_attachments = virus_attachments
    @receivers = receivers
    @user = user
    mail(:to => user.email,
         :subject => 'ウィルスファイル検出のご連絡',
         :reply_to => user.email)
  end

  def requested_send_virus_info_report(requested_matter, virus_attachments, user)
    @requested_matter = requested_matter
    @virus_attachments = virus_attachments
    @user = user
    mail(:to => user.email,
         :subject => 'ウィルスファイル検出のご連絡',
         :reply_to => user.email)
  end

  def send_matter_moderate_report(send_matter, send_moderater, moderate_user, url)
    @send_matter = send_matter
    @send_moderater = send_moderater
    @moderate_user = moderate_user
    @url = url
    mail(:to => moderate_user.email,
         :subject => 'ファイル送信決裁のご連絡',
         :reply_to => send_matter.mail_address)
  end

  def send_matter_moderate_copied_report(send_matter, send_moderate, url)
    @send_matter = send_matter
    @send_moderate = send_moderate
    @url = url
    mail(:to => send_matter.mail_address,
         :subject => 'ファイル送信決裁のご連絡【控】',
         :reply_to => send_matter.mail_address)
  end

  def send_matter_moderate_result_report(send_matter, send_moderate, url)
    @send_matter = send_matter
    @send_moderate = send_moderate
    @url = url
    mail(:to => send_matter.mail_address,
         :subject => 'ファイル送信決裁結果のご連絡',
         :reply_to => send_matter.mail_address)
  end

  def request_matter_moderate_report(request_matter, request_moderater, moderate_user, url)
    @request_matter = request_matter
    @request_moderater = request_moderater
    @moderate_user = moderate_user
    @url = url
    mail(:to => moderate_user.email,
         :subject => 'ファイル依頼決裁のご連絡',
         :reply_to => request_matter.mail_address)
  end

  def request_matter_moderate_copied_report(request_matter, request_moderate, url)
    @request_matter = request_matter
    @request_moderate = request_moderate
    @url = url
    mail(:to => request_matter.mail_address,
         :subject => 'ファイル依頼決裁のご連絡【控】',
         :reply_to => request_matter.mail_address)
  end

  def request_matter_moderate_result_report(request_matter, request_moderater, url)
    @request_matter = request_matter
    @request_moderater = request_moderater
    @url = url
    mail(:to => request_matter.mail_address,
         :subject => 'ファイル依頼決裁結果のご連絡',
         :reply_to => request_matter.mail_address)
  end
end
