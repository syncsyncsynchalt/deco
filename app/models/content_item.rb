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
class ContentItem < ActiveRecord::Base
  # attr_accessible :title, :body
  
  # カテゴリ　1:見出し、2:文、3:画像、4:リンク、5:画像リンク
  validates :category, presence: true
  validates :category, allow_blank: true, 
    inclusion: { in: [1, 2, 3, 4, 5] }
  
  # 1:見出し
  with_options if: proc { |s| s.category.to_i == 1 } do |op|
    op.validates :string1, presence: true
    op.validates :string1, allow_blank: true,
      length: { maximum: 50 }
  end
  
  # 2:文
  with_options if: proc { |s| s.category.to_i == 2 } do |op|
    op.validates :text1, presence: true
    op.validates :text1, allow_blank: true,
      length: { maximum: 3000 }

    op.validates :flg, presence: true
    op.validates :flg, allow_blank: true, 
      inclusion: { in: [0, 1] }
  end
  
  # 3:画像
  with_options if: proc { |s| s.category.to_i == 3 } do |op|
    op.validates :image, presence: true
#    op.validates :image, allow_blank: true
    op.validate :validate_image
  end

  # 4:リンク
  with_options if: proc { |s| s.category.to_i == 4 } do |op|
    op.validates :string1, presence: true
    op.validates :string1, allow_blank: true,
      length: { maximum: 40 }

    op.validates :url, presence: true
    op.validates :url, allow_blank: true, 
      length: { maximum: 255 }, 
      format: { with: /\Ahttps?:\/\/[\w\/:%#\$&\?\(\)~\.=\+\-]+\z/i, message: 'が不正です。' }

    op.validates :flg, presence: true
    op.validates :flg, allow_blank: true, 
      inclusion: { in: [0, 1] }
  end

  # 5:画像リンク
  with_options if: proc { |s| s.category.to_i == 5 } do |op|
    op.validates :image, presence: true
#    op.validates :image, allow_blank: true
    op.validate :validate_image

    op.validates :url, presence: true
    op.validates :url, allow_blank: true, 
      length: { maximum: 255 }, 
      format: { with: /\Ahttps?:\/\/[\w\/:%#\$&\?\(\)~\.=\+\-]+\z/i, message: 'が不正です。' }

    op.validates :flg, presence: true
    op.validates :flg, allow_blank: true, 
      inclusion: { in: [0, 1] }
  end

  # ファイル検証（return_flag=true の場合はメッセージも返す）
  def validate_image(return_flag = false)
    return if self.image.blank?

    content_type = self.text1
    if !(content_type =~ /image/)
      result = "画像データではありません"
      errors.add(:image, "は画像データではありません")
    elsif !(content_type =~ /jpeg|jpg|JPEG|JPG/)
      result = "JPEG画像を選択してください"
      errors.add(:image, "はJPEG画像を選択してください")
    elsif (self.image.size > 12.megabytes)
      result = "ファイルサイズは12MB以下にしてください"
      errors.add(:image, "のファイルサイズは12MB以下にしてください")
    end

    return result if return_flag
  end
end
