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
class AppEnv < ActiveRecord::Base
  # attr_accessible :title, :body
  
  attr_reader :term, :unit  # 期限用
  def term=(value)
    @term = value
    conv_term_to_value
  end
  def unit=(value)
    @unit = value
    conv_term_to_value
  end

  validates :key, presence: true
#  validates :key, allow_blank: true

  # カテゴリ　0:全体、1:システム管理者、2:リモートユーザ、3:ローカルユーザ
  validates :category, presence: true
  validates :category, allow_blank: true, 
    inclusion: { in: [0, 1, 2, 3] }
  
  # LOCAL_DOMAINS
  with_options if: proc { |s| s.key.to_s == 'LOCAL_DOMAINS' } do |op|
    op.validates :value, presence: true
    op.validates :value, allow_blank: true,
      length: { maximum: 253 }, 
      format: { with: /\A[a-zA-Z0-9\-]+(?:\.[a-zA-Z0-9-]+)*\z/, message: "ドメインが不正です" }
  end

  # LOCAL_IPS
  with_options if: proc { |s| s.key.to_s == 'LOCAL_IPS' } do |op|
    op.validates :value, presence: true
    op.validates :value, allow_blank: true,
      format: { with: /\A(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])((\/(([0-2]?[0-9])|(3[0-2])|(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])))?)\z/, message: "ＩＰアドレスが不正です" }
  end

  # URL
  with_options if: proc { |s| s.key.to_s == 'URL' } do |op|
    op.validates :value, presence: true
    op.validates :value, allow_blank: true,
      length: { maximum: 255 }
  end

  # FILE_DIR
  with_options if: proc { |s| s.key.to_s == 'FILE_DIR' } do |op|
    op.validates :value, presence: true
    op.validates :value, allow_blank: true,
      length: { maximum: 255 }
    op.validate :validate_directory
  end

  # REQUEST_PERIOD
  with_options if: proc { |s| s.key.to_s == 'REQUEST_PERIOD' } do |op|
#    op.validates :value, presence: true
    op.validates :value, allow_blank: true,
      numericality: { only_integer: true }
    op.validate :validate_term_unit
  end

  # FROM_MAIL_ADDRESS
  with_options if: proc { |s| s.key.to_s == 'FROM_MAIL_ADDRESS' } do |op|
    op.validates :value, presence: true
    op.validates :value, allow_blank: true,
      length: { maximum: 255 },
      format: { with: /\A[a-zA-Z0-9.!#\$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*\z/, message: "メールアドレスが不正です" }
  end

  # PASSWORD_AUTOMATION
  with_options if: proc { |s| s.key.to_s == 'PASSWORD_AUTOMATION' } do |op|
    op.validates :value, presence: true
    op.validates :value, allow_blank: true, 
      inclusion: { in: ['0', '1'] }
  end

  # ENABLE_SSL
  with_options if: proc { |s| s.key.to_s == 'ENABLE_SSL' } do |op|
    op.validates :value, presence: true
    op.validates :value, allow_blank: true, 
      inclusion: { in: ['0', '1'] }
  end

  # VIRUS_CHECK
  with_options if: proc { |s| s.key.to_s == 'VIRUS_CHECK' } do |op|
    op.validates :value, presence: true
    op.validates :value, allow_blank: true, 
      inclusion: { in: ['0', '1'] }
  end

  # VIRUS_CHECK_NOTICE
  with_options if: proc { |s| s.key.to_s == 'VIRUS_CHECK_NOTICE' } do |op|
    op.validates :value, presence: true
    op.validates :value, allow_blank: true, 
      inclusion: { in: ['0', '1'] }
  end

  # MODERATE_DEFAULT
  with_options if: proc { |s| s.key.to_s == 'MODERATE_DEFAULT' } do |op|
#    op.validates :value, presence: true
#    op.validates :value, allow_blank: true,
#      length: { maximum: 255 }
  end

  # SEND_MAIL_TITLE
  with_options if: proc { |s| s.key.to_s == 'SEND_MAIL_TITLE' } do |op|
    op.validates :value, presence: true
    op.validates :value, allow_blank: true,
      length: { maximum: 20 }
  end

  # SEND_MAIL_CONTENT
  with_options if: proc { |s| s.key.to_s == 'SEND_MAIL_CONTENT' } do |op|
    op.validates :value, presence: true
    op.validates :value, allow_blank: true,
      length: { maximum: 20 }
  end

  # FILE_LIFE_PERIOD
  with_options if: proc { |s| s.key.to_s == 'FILE_LIFE_PERIOD' } do |op|
#    op.validates :value, presence: true
    op.validates :value, allow_blank: true,
      numericality: { only_integer: true }
    op.validate :validate_term_unit
  end

  # FILE_LIFE_PERIOD_DEF
  with_options if: proc { |s| s.key.to_s == 'FILE_LIFE_PERIOD_DEF' } do |op|
#    op.validates :value, presence: true
#    op.validates :value, allow_blank: true,
#      length: { maximum: 255 }
  end

  # RECEIVERS_LIMIT
  with_options if: proc { |s| s.key.to_s == 'RECEIVERS_LIMIT' } do |op|
    op.validates :value, presence: true
    op.validates :value, allow_blank: true,
      numericality: { 
        only_integer: true, 
        greater_than_or_equal_to: 1, 
        less_than_or_equal_to: 100 
      }
  end

  # FILE_SEND_LIMIT
  with_options if: proc { |s| s.key.to_s == 'FILE_SEND_LIMIT' } do |op|
    op.validates :value, presence: true
    op.validates :value, allow_blank: true,
      numericality: { 
        only_integer: true, 
        greater_than_or_equal_to: 1, 
        less_than_or_equal_to: 100 
      }
  end

  # FILE_SIZE_LIMIT
  with_options if: proc { |s| s.key.to_s == 'FILE_SIZE_LIMIT' } do |op|
    op.validates :value, presence: true
    op.validates :value, allow_blank: true,
      numericality: { 
        only_integer: true, 
        greater_than_or_equal_to: 1, 
        less_than_or_equal_to: 102400 
      }
  end

  # FILE_TOTAL_SIZE_LIMIT
  with_options if: proc { |s| s.key.to_s == 'FILE_TOTAL_SIZE_LIMIT' } do |op|
    op.validates :value, presence: true
    op.validates :value, allow_blank: true,
      numericality: { 
        only_integer: true, 
        greater_than_or_equal_to: 1, 
        less_than_or_equal_to: 204800 
      }
  end

  # MESSAGE_LIMIT
  with_options if: proc { |s| s.key.to_s == 'MESSAGE_LIMIT' } do |op|
    op.validates :value, presence: true
    op.validates :value, allow_blank: true,
      numericality: { 
        only_integer: true, 
        greater_than_or_equal_to: 1, 
        less_than_or_equal_to: 3000 
      }
  end

  # PW_LENGTH_MIN
  with_options if: proc { |s| s.key.to_s == 'PW_LENGTH_MIN' } do |op|
    op.validates :value, presence: true
    op.validates :value, allow_blank: true,
      numericality: { 
        only_integer: true, 
        greater_than_or_equal_to: 1, 
        less_than_or_equal_to: 64 
      }
  end

  # PW_LENGTH_MAX
  with_options if: proc { |s| s.key.to_s == 'PW_LENGTH_MAX' } do |op|
    op.validates :value, presence: true
    op.validates :value, allow_blank: true,
      numericality: { 
        only_integer: true, 
        greater_than_or_equal_to: 1, 
        less_than_or_equal_to: 64 
      }
  end

  # PW_LENGTH_MIN OR PW_LENGTH_MAX
  with_options if: proc { |s| ['PW_LENGTH_MIN', 'PW_LENGTH_MAX'].include?(s.key.to_s) } do |op|
    op.validate :validate_pw_length_min_max
  end

  # 期間→値（秒換算）
  def conv_term_to_value
    if self.unit.to_i == 0 
      if self.term.to_i.between?(1, 23)
        self.value = self.term.to_i * 60 * 60
        self.note = "#{self.term}時間"
      else
        self.value = nil
        self.note = nil
      end
    elsif self.unit.to_i == 1 
      if self.term.to_i.between?(1, 14)
        self.value = self.term.to_i * 60 * 60 * 24
        self.note = "#{self.term}日"
      else
        self.value = nil
        self.note = nil
      end
    else
      self.value = nil
      self.note = nil
    end
  end

  # 値（秒換算）→期間
  def conv_value_to_term
    if (self.term.blank? || self.unit.blank?) && self.value.present?
      if self.value.to_i >= (60 * 60 * 24)
        self.term = self.value.to_i / (60 * 60 * 24)
        self.unit = 1
      else
        self.term = self.value.to_i / (60 * 60)
        self.unit = 0
      end
    end
  end

  # ディレクトリ検証（return_flag=true の場合はメッセージも返す）
  def validate_directory(return_flag = false)
    result = ''

    if self.value.blank?
      # 入力値が正しくありません
      result =  "有効なディレクトリを指定してください"
      errors.add(:base, result)
    elsif !File.exists?(self.value)
      # ディレクトリが存在しません
      result =  "有効なディレクトリを指定してください"
      errors.add(:base, result)
    elsif !File.directory?(self.value)
      # 入力値はディレクトリではありません
      result =  "有効なディレクトリを指定してください"
      errors.add(:base, result)
    end

    return result if return_flag
  end
  
  # 期間検証（return_flag=true の場合はメッセージも返す）
  def validate_term_unit(return_flag = false)
    result = ''

    if self.term.present? && self.unit.present?
      conv_term_to_value
    elsif (self.term.blank? || self.unit.blank?)
      conv_value_to_term
    end

    if self.unit.to_i == 0 
      unless self.term.to_i.between?(1, 23)
        # 1から23の間の数値を指定してください
        result = "1から23の間の数値を指定してください"
        errors.add(:base, result)
      end
    elsif self.unit.to_i == 1 
      unless self.term.to_i.between?(1, 14)
        # 1から14の間の数値を指定してください
        result = "1から14の間の数値を指定してください"
        errors.add(:base, result)
      end
    else
      # 日/時の指定が不正です
      result = "日/時の指定が不正です"
      errors.add(:base, result)
    end

    return result if return_flag
  end

  # パスワード長検証（return_flag=true の場合はメッセージも返す）
  def validate_pw_length_min_max(return_flag = false)
    result = ''

    max = nil
    min = nil
    if self.key == 'PW_LENGTH_MIN'
      min = self.value
      app_env = AppEnv.where(category: self.category, key: 'PW_LENGTH_MAX').first
      max = app_env.present? ? app_env.value : nil
      return if (min.blank? || max.blank?)
      if min.to_i > max.to_i
        result = "最長パスワード長（#{max.to_i}文字）より小さい数字にしてください"
        errors.add(:base, result)
      end
    elsif self.key == 'PW_LENGTH_MAX'
      max = self.value
      app_env = AppEnv.where(category: self.category, key: 'PW_LENGTH_MIN').first
      min = app_env.present? ? app_env.value : nil
      return if (min.blank? || max.blank?)
      if min.to_i > max.to_i
        result = "最短パスワード長（#{min.to_i}文字）より大きい数字にしてください"
        errors.add(:base, result)
      end
    end 

    return result if return_flag
  end
end
