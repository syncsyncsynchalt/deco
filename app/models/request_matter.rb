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
class RequestMatter < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :requested_matters
  has_one :request_moderate
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
      requested_matters =RequestedMatter.arel_table
      includes(:requested_matters).where(requested_matters[select.to_sym].matches('%'+text.to_s+'%'))
    end
  }
  scope :with_order, ->(sort_select_1, sort_select_2) {    order(arel_table[sort_select_1.to_sym].__send__(sort_select_2))
  }
  scope :search_q, ->(user_id, conditions) {
    joins(:requested_matters).
    with_begin_date(conditions[:begin_date]).
    with_end_date(conditions[:end_date]).
    with_receivers(conditions[:search_select], conditions[:search_text]).
    where(:user_id => user_id).
    with_order(conditions[:sort_select_1], conditions[:sort_select_2])
  }

  # 依頼元名
  validates :name, presence: true
  validates :name, allow_blank: true,
    length: { maximum: 72 }
  
  # 依頼元メールアドレス
  validates :mail_address, presence: true
  validates :mail_address, allow_blank: true, 
    length: { maximum: 255 },
    format: { with: /\A[a-zA-Z0-9.!#\$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*\z/i, message: 'の値が不正です。正しいメールアドレスを入力してください。' }

  # メッセージ
  #validates :message, presence: true
  #validates :message, allow_blank: true
  validate :validate_message

  # url（URLに付与するトークン）
  #validates :url, presence: true
  #validates :url, allow_blank: true
  
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
  
end
