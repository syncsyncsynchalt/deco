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

# -*- coding: utf-8 -*-
class Notification < ActionMailer::Base
helper :application

  # fromのアドレスを変えて下さい
  def send_report(send_matter, receiver, attachments, url, sent_at = Time.now)
    subject    'ファイル送信のご連絡'
    recipients receiver.mail_address
    from       "<name1@sample.com>"
    sent_on    sent_at
    body       :send_matter => send_matter,
               :receiver => receiver,
               :attachments => attachments,
               :url => url
  end

  def send_result_report(send_matter, receivers, attachments, sent_at = Time.now)
    url = AppEnv.find(:first, :conditions => { :key => "URL" })
    subject    'ファイル送信のご連絡【控】'
    recipients send_matter.mail_address
    from       "<name1@sample.com>"
    reply_to   send_matter.mail_address
    sent_on    sent_at
    body       :send_matter => send_matter,
               :receivers => receivers,
               :attachments => attachments,
               :url => url
  end

  def receive_report(send_matter, receiver, attachment, sent_at = Time.now)
    subject    'ファイルダウンロードのご連絡'
    recipients send_matter.mail_address
    from       "<name1@sample.com>"
    reply_to   receiver.mail_address
    sent_on    sent_at
    body       :send_matter => send_matter,
               :receiver => receiver,
               :attachment => attachment
  end

  def request_report(request_matter, mail_receiver, mail_receiver_addr, url, pass, request_period, sent_at = Time.now)
    subject    'ファイル送信依頼'
    recipients mail_receiver_addr
    from       "<name1@sample.com>"
    reply_to   request_matter.mail_address
    sent_on    sent_at
    body       :request_matter => request_matter,
               :receiver => mail_receiver,
               :url => url,
               :pass => pass,
               :request_period => request_period
  end

  def request_copied_report(request_matter, requested_matters, url, request_period, sent_at = Time.now)
    subject    'ファイル送信依頼【控】'
    recipients request_matter.mail_address
    from       "<name1@sample.com>"
    reply_to   request_matter.mail_address
    sent_on    sent_at
    body       :request_matter => request_matter,
               :requested_matters => requested_matters,
               :url => url,
               :request_period => request_period
  end

  def file_delete_report(send_matter, receiver, attachment, sent_at = Time.now)
    subject    'ファイル削除のご連絡'
    recipients receiver.mail_address
    from       "<name1@sample.com>"
    reply_to   send_matter.mail_address
    sent_on    sent_at
    body       :send_matter => send_matter,
               :receiver => receiver,
               :attachment => attachment
  end

  def file_delete_result_report(send_matter, receivers, attachment, sent_at = Time.now)
    url = AppEnv.find(:first, :conditions => { :key => "URL"})
    subject    'ファイル削除のご連絡【控】'
    recipients send_matter.mail_address
    from       "<name1@sample.com>"
    reply_to   send_matter.mail_address
    sent_on    sent_at
    body       :send_matter => send_matter,
               :receivers => receivers,
               :attachment => attachment,
               :url => url
  end

  def requested_send_report(requested_matter, attachments, url, sent_at = Time.now)
    subject    'ファイル送信のご連絡'
    recipients requested_matter.request_matter.mail_address
    from       "<name1@sample.com>"
    reply_to   requested_matter.mail_address
    sent_on    sent_at
    body       :requested_matter => requested_matter,
               :attachments => attachments,
               :url => url
  end

  def requested_send_copied_report(requested_matter, attachments, url, url2, sent_at = Time.now)
    subject    'ファイル送信のご連絡【控】'
    recipients requested_matter.mail_address
    from       "<name1@sample.com>"
    reply_to   requested_matter.mail_address
    sent_on    sent_at
    body       :requested_matter => requested_matter,
               :attachments => attachments,
               :url => url,
               :url2 => url2
  end

  def requested_file_delete_report(requested_matter, attachment, sent_at = Time.now)
    subject    'ファイル削除のご連絡'
    recipients requested_matter.request_matter.mail_address
    from       "<name1@sample.com>"
    reply_to   requested_matter.mail_address
    sent_on    sent_at
    body       :name => requested_matter.request_matter.name,
               :sender => requested_matter.name,
               :attachment => attachment
  end

  def requested_file_delete_copied_report(requested_matter, attachment, url, sent_at = Time.now)
    subject    'ファイル削除のご連絡【控】'
    recipients requested_matter.mail_address
    from       "<name1@sample.com>"
    reply_to   requested_matter.mail_address
    sent_on    sent_at
    body       :requested_matter => requested_matter,
               :attachment => attachment,
               :url => url
  end

  def requested_file_dl_report(requested_attachment, sent_at = Time.now)
    subject    'ファイルダウンロード完了のご連絡'
    recipients requested_attachment.requested_matter.mail_address
    from       "<name1@sample.com>"
    reply_to   requested_attachment.requested_matter.request_matter.mail_address
    sent_on    sent_at
    body       :requested_matter => requested_attachment.requested_matter,
               :attachment => requested_attachment
  end
end
