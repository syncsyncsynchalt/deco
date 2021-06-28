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
class Receiver < ActiveRecord::Base
  belongs_to(:send_matter)
  has_many :file_dl_checks
  has_many :attachments, :through => :file_dl_checks

  # 送信情報ID
  #validates :send_matter_id, presence: true
  #validates :send_matter_id, allow_blank: true

  # 受信者名
  validates :name, presence: true
  validates :name, allow_blank: true,
    length: { maximum: 72 }
  
  # 受信者メールアドレス
  validates :mail_address, presence: true
  validates :mail_address, allow_blank: true, 
    length: { maximum: 255 },
    format: { with: /\A[a-zA-Z0-9.!#\$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*\z/i, message: 'の値が不正です。正しいメールアドレスを入力してください。' }

  # url（URLに付与するトークン）
  #validates :url, presence: true
  #validates :url, allow_blank: true
end
