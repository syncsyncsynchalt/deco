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
class RequestedMatter < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :request_matter
  has_many :requested_attachments

  # 依頼情報ID
  #validates :request_matter_id, presence: true
  #validates :request_matter_id, allow_blank: true

  # 依頼先名
  validates :name, presence: true
  validates :name, allow_blank: true,
    length: { maximum: 72 }
  
  # 依頼先メールアドレス
  validates :mail_address, presence: true
  validates :mail_address, allow_blank: true, 
    length: { maximum: 255 },
    format: { with: /\A[a-zA-Z0-9.!#\$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*\z/i, message: 'の値が不正です。正しいメールアドレスを入力してください。' }
  
  # 送信パスワード
  #validates :send_password, presence: true 
  #validates :send_password, allow_blank: true
  
  with_options if: proc { |s| s.file_up_date.present? } do |op|

    # ダウンロードパスワード
    op.validates :receive_password, presence: true 
    op.validates :receive_password, allow_blank: true, 
      format: { with: /\A[a-zA-Z0-9]+\z/i, message: 'は半角英数字で入力してください。' }
    op.validate :validate_receive_password
  
    # 受信パスワードの通知方法（0:自分で通知、1:システムで行う）
    op.validates :password_notice, presence: true
    op.validates :password_notice, allow_blank: true,
      numericality: { only_integer: true }, 
      inclusion: { in: [0, 1] }

    # ダウンロード完了通知メール
    op.validates :download_check, presence: true
    op.validates :download_check, allow_blank: true,
      numericality: { only_integer: true }, 
      inclusion: { in: [0, 1] }

    # メッセージ
    #op.validates :message, presence: true
    #op.validates :message, allow_blank: true
    op.validate :validate_message

    # ファイル保存期間（秒）
    op.validates :file_life_period, presence: true
    op.validates :file_life_period, allow_blank: true,
      numericality: { only_integer: true }
    op.validate :validate_file_life_period

  end
  
  # url（URLに付与するトークン）
  #validates :url, presence: true
  #validates :url, allow_blank: true

  # ステータス
  #validates :status, presence: true
  #validates :status, allow_blank: true

  # 中継ID
  #validates :relayid, presence: true
  #validates :relayid, allow_blank: true

  # アップロード日時
  #validates :file_up_date, presence: true
  #validates :file_up_date, allow_blank: true

  # 操作用URL（URLに付与するトークン）
  #validates :url_operation, presence: true
  #validates :url_operation, allow_blank: true
  
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
