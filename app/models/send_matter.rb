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
class SendMatter < ActiveRecord::Base
  has_many :receivers
  has_many :attachments
  has_one :send_moderate
  belongs_to :user, optional: true

  scope :with_begin_date, ->(begin_date) {
    unless begin_date.blank?
      where(arel_table[:created_at].gteq(Date.parse(begin_date).to_datetime.beginning_of_day.to_s(:db)))
    end
  }
  scope :with_end_date, ->(end_date) {
    unless end_date.blank?
      where(arel_table[:created_at].lteq(Date.parse(end_date).to_datetime.end_of_day.to_s(:db)))
    end
  }
  scope :with_receivers, ->(select, text) {
    unless select.blank? || text.blank?
      receivers =Receiver.arel_table
      includes(:receivers).where(receivers[select.to_sym].matches('%'+text.to_s+'%'))
    end
  }
  scope :with_order, ->(sort_select_1, sort_select_2) {
    order(arel_table[sort_select_1.to_sym].__send__(sort_select_2))
  }
  scope :search_q, ->(user_id, conditions) {
    joins(:receivers).
    with_begin_date(conditions[:begin_date]).
    with_end_date(conditions[:end_date]).
    with_receivers(conditions[:search_select], conditions[:search_text]).
    where(:user_id => user_id).
    with_order(conditions[:sort_select_1], conditions[:sort_select_2])
  }

  scope :with_select, ->(){
    send_matters = SendMatter.arel_table
    receivers =Receiver.arel_table
    select("receivers.name")
  }

  scope :test_q, ->() {
    send_matters = SendMatter.arel_table
    receivers =Receiver.arel_table
    col = [Receiver.arel_table[:name], SendMatter.arel_table[:created_at]]
    select(col).to_sql
#    send_ma#tters = SendMatter.arel_table
#    receivers = Receiver.arel_table
#    send_matters = send_matters.join(receivers).on(send_matters[:id].eq(receivers[:send_matter_id]))
#      joins(receivers).on(send_matters[:id].eq(receivers[:send_matter_id]))

#    send_matters = send_matters.select(receivers[:name].as())
#    select('name as OOOOOO').where("")
  }

  scope :date_range, lambda { |from, to| where("send_matters.created_at between ? and ?", from, to)}
  scope :search_text, lambda { |select, text| where("#{select} LIKE ?", '%'+text+'%')}

  # 送信者名
  validates :name, presence: true
  validates :name, allow_blank: true,
    length: { maximum: 72 }
  
  # 送信者メールアドレス
  validates :mail_address, presence: true
  validates :mail_address, allow_blank: true, 
    length: { maximum: 255 },
    format: { with: /\A[a-zA-Z0-9.!#\$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*\z/i, message: 'の値が不正です。正しいメールアドレスを入力してください。' }
  
  # ダウンロードパスワード
  validates :receive_password, presence: true 
  validates :receive_password, allow_blank: true, 
    format: { with: /\A[a-zA-Z0-9]+\z/i, message: 'は半角英数字で入力してください。' }
  validate :validate_receive_password
  
  # 受信パスワードの通知方法（0:自分で通知、1:システムで行う）
  validates :password_notice, presence: true
  validates :password_notice, allow_blank: true,
    numericality: { only_integer: true }, 
    inclusion: { in: [0, 1] }

  # ダウンロード完了通知メール
  validates :download_check, presence: true
  validates :download_check, allow_blank: true,
    numericality: { only_integer: true }, 
    inclusion: { in: [0, 1] }

  # メッセージ
  #validates :message, presence: true
  #validates :message, allow_blank: true
  validate :validate_message

  # ファイル保存期間（秒）
  validates :file_life_period, presence: true
  validates :file_life_period, allow_blank: true,
    numericality: { only_integer: true }
  validate :validate_file_life_period

  # url（URLに付与するトークン）
  #validates :url, presence: true
  #validates :url, allow_blank: true

  # ステータス
  #validates :status, presence: true
  #validates :status, allow_blank: true

  # 中継ID
  #validates :relayid, presence: true
  #validates :relayid, allow_blank: true

  # 決裁フラグ
  #validates :moderate_flag, presence: true
  #validates :moderate_flag, allow_blank: true

  # 決裁結果
  #validates :moderate_result, presence: true
  #validates :moderate_result, allow_blank: true

  # 送信日時
  #validates :sent_at, presence: true
  #validates :sent_at, allow_blank: true

  # ユーザID
  #validates :user_id, presence: true
  #validates :user_id, allow_blank: true

  # ダウンロードパスワード長検証（return_flag=true の場合はメッセージも返す）
  def validate_receive_password(return_flag = false)
    return if self.receive_password.blank?
    
    result = ''
    
    receive_password = self.receive_password.to_s
    len = receive_password.length
    
#    category = self.user_id.present? ? 2 : 3
    category = (Thread.current[:user_category] || 3)

    app_env = AppEnv.where(key: 'PW_LENGTH_MIN', category: category).first
    min = app_env.try(:value).to_i
    app_env = AppEnv.where(key: 'PW_LENGTH_MAX', category: category).first
    max = app_env.try(:value).to_i

    if len < min
      result = "ダウンロードパスワードは#{min}文字以上にしてください。"
      errors.add(:receive_password, "は#{min}文字以上にしてください")
    elsif max < len
      result = "ダウンロードパスワードは#{max}文字以下にしてください。"
      errors.add(:receive_password, "は#{max}文字以下にしてください")
    end

    return result if return_flag
  end
  
  # メッセージ検証（return_flag=true の場合はメッセージも返す）
  def validate_message(return_flag = false)
    return if self.message.blank?

    result = ''

    message = self.message.to_s
    len = message.length
    
#    category = self.user_id.present? ? 2 : 3
    category = (Thread.current[:user_category] || 3)

    app_env = AppEnv.where(key: 'MESSAGE_LIMIT', category: category).first
    limit = app_env.try(:value).to_i

    if len > limit
      # ファイル保存期間の指定が不正です
      errors.add(:message, "は#{limit}文字以下にしてください")
      result = "メッセージは#{limit}文字以下にしてください"
    end

    return result if return_flag
  end
  
  # 保存期間検証（return_flag=true の場合はメッセージも返す）
  def validate_file_life_period(return_flag = false)
    return if self.file_life_period.blank?

    result = ''

    periods = Array.new
    periods += (1..23).map{|i| i * 60 * 60}
    periods += (1..14).map{|i| i * 60 * 60 * 24}

    unless periods.include?(self.file_life_period.to_i) 
      # ファイル保存期間の指定が不正です
      errors.add(:file_life_period, "の指定が不正です")
      result = "ファイル保存期間の指定が不正です"
    end

    return result if return_flag
  end

end
