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
class Announcement < ActiveRecord::Base
  # attr_accessible :title, :body
  
  # タイトル
  validates :title, presence: true
  validates :title, allow_blank: true,
    length: { maximum: 20 }

  # 内容
  validates :body, presence: true
  validates :body, allow_blank: true,
    length: { maximum: 3000 }

  validates :show_flg, presence: true
  validates :show_flg, allow_blank: true,
    numericality: { only_integer: true }, 
    inclusion: { in: [0, 1] }

  validates :body_show_flg, presence: true
  validates :body_show_flg, allow_blank: true,
    numericality: { only_integer: true }, 
    inclusion: { in: [0, 1] }

end
