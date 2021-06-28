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
class AddressBook < ActiveRecord::Base
  belongs_to :user
#  attr_accessible :organization, :email, :from_email, :name, :notes, :user_id

#  paginates_per 8

  # 組織名
#  validates :organization, presence: true
  validates :organization, allow_blank: true,
    length: { maximum: 20 }
  
  # ユーザ名
  validates :name, presence: true
  validates :name, allow_blank: true,
    length: { maximum: 50 }
  
  # メールアドレス
  validates :email, presence: true
  validates :email, allow_blank: true, 
    length: { maximum: 255 },
    format: { with: /\A[a-zA-Z0-9.!#\$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*\z/i, message: 'の値が不正です。正しいメールアドレスを入力してください。' }
  
  # 備考
#  validates :notes, presence: true
  validates :notes, allow_blank: true,
    length: { maximum: 100 }

end
