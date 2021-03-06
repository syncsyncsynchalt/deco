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
class Moderate < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :moderaters
  has_many :send_moderates
  has_many :request_moderates
  has_many :user
  
  # 決済ルート名
  validates :name, presence: true
  validates :name, allow_blank: true,
    length: { maximum: 30 }
  
  # ルート
#  validates :route, presence: true
#  validates :route, allow_blank: true
  
  # タイプフラグ
  validates :type_flag, presence: true
  validates :type_flag, allow_blank: true, 
    inclusion: { in: [0, 1] }

  # 使用フラグ
#  validates :use_flag, presence: true
#  validates :use_flag, allow_blank: true, 
#    inclusion: { in: [0, 1] }
end
