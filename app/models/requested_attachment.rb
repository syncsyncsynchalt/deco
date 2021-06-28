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
class RequestedAttachment < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :requested_matter, optional: true
  has_many :requested_file_dl_logs

  # 依頼送信情報ID
  #validates :requested_matter_id, presence: true
  #validates :requested_matter_id, allow_blank: true

  # ファイル名
  #validates :name, presence: true
  #validates :name, allow_blank: true

  # ファイルサイズ
  #validates :size, presence: true
  #validates :size, allow_blank: true

  # コンテントタイプ
  #validates :content_type, presence: true
  #validates :content_type, allow_blank: true

  # ダウンロードフラグ
  #validates :download_flg, presence: true
  #validates :download_flg, allow_blank: true

  # 中継ID
  #validates :relayid, presence: true
  #validates :relayid, allow_blank: true

  # ウィルスチェック結果
  #validates :virus_check, presence: true
  #validates :virus_check, allow_blank: true

  # ファイル保存場所
  #validates :file_save_pass, presence: true
  #validates :file_save_pass, allow_blank: true
end
