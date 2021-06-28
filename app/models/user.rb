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
require 'digest/sha1'
class User < ActiveRecord::Base
  has_many :moderaters
  has_many :send_moderaters
  has_many :request_moderaters
  has_many :address_books
  has_many :send_matters
  has_many :request_matters
  belongs_to :moderate, optional: true

  attr_accessor :password
#  attr_accessible :login, :password_digest
#  attr_accessor :password_digest
#  has_secure_password
  before_save :encrypt_password

#  validates_uniqueness_of :login, :message => '同じユーザIDが既に登録されています'
#  validates_presence_of :name, :if => :password_required?, :message => 'ユーザ名を入力してください'
#  validates_presence_of :email, :if => :password_required?, :message => 'メールアドレスを入力してください'
#  validates_presence_of :password, :if => :password_required?, :message => 'パスワードを入力してください'
#  validates_presence_of :password_confirmation, :if => :password_required?, :message => 'パスワード(確認)を入力してください'
#  validates_length_of :password, :within => 4..40, :if => :password_required?, :message => 'パスワードは4～40文字です'
#  validates_confirmation_of :password, :if => :password_required?, :message => 'パスワードが一致しません'

  # ユーザID
  validates :login, presence: true
  validates :login, allow_blank: true,
    length: { maximum: 30 },
    format: { with: /\A[a-zA-Z0-9]+\z/i, message: 'は半角英数字で入力してください。' },
    uniqueness: {message: '同じユーザIDが既に登録されています'}

  # ユーザ名
  validates :name, presence: true
  validates :name, allow_blank: true,
    length: { maximum: 50 }
  
  with_options if: :password_required? do |op|
    # パスワード
    op.validates :password, presence: true 
    op.validates :password, allow_blank: true, 
      length: { within: 4..40 },
      format: { with: /\A[a-zA-Z0-9!-\/:-@\[-`\{-~]+\z/i, message: 'は半角英数字および記号で入力してください。' }

    # 確認用パスワード
    op.validates :password_confirmation, presence: true

    # パスワードと確認用パスワードの確認チェック
    op.validates :password,
      confirmation: true
  end
   
  # メールアドレス
  validates :email, presence: true
  validates :email, allow_blank: true, 
    length: { maximum: 255 },
    format: { with: /\A[a-zA-Z0-9.!#\$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*\z/i, message: 'の値が不正です。正しいメールアドレスを入力してください。' }
  
  # 備考
#  validates :note, presence: true
  validates :note, allow_blank: true,
    length: { maximum: 400 }

  # カテゴリ　1:システム管理者、2:リモートユーザ
  validates :category, presence: true
  validates :category, allow_blank: true, 
    inclusion: { in: [1, 2] }
  
#  validates :moderate_id, presence: true
#  validates :moderate_id, allow_blank: true 
  validate :validate_moderate_id
  
  # 「あなたの名前」の先頭に追加する文字列
#  validates :from_organization_add, presence: true
  validates :from_organization_add, allow_blank: true,
    length: { maximum: 20 }

#  validates :to_organization_add, presence: true
#  validates :to_organization_add, allow_blank: true 
  validates :to_organization_add,  
    inclusion: { in: [true, false] }
  
  #  password_digest = Digest::SHA1.hexdigest(password)
  def self.sha1(pass)
    Digest::SHA1.hexdigest("---changme--#{pass}--")
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

#  def authenticated?(password)
#    crypted_password == encrypt(password)
#  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def authenticate(password)
    if encrypt(password) == crypted_password
      self
    else
      false
    end
  end
  
  # ユーザID検証（return_flag=true の場合はメッセージも返す）
  def validate_login(return_flag = false)
    return if self.login.blank?
    
    result = ''
    
    users = User.where(login: self.login)
    if self.id.present?
      users = users.where("users.id != ?", self.id)
    end
    if users.exists?
      result = "同じユーザIDが既に登録されています。"
      errors.add(:base, "同じユーザIDが既に登録されています")
    end

    return result if return_flag
  end
  
  # 決済ID検証（return_flag=true の場合はメッセージも返す）
  def validate_moderate_id(return_flag = false)
    return if self.moderate_id.blank?
    
    result = ''
    
    if Moderate.where(id: self.moderate_id).empty?
      result = "決済ルートは存在しません。"
      errors.add(:moderate_id, "は存在しません")
    end

    return result if return_flag
  end

  protected

  # before filter
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    crypted_password.blank? || !password.blank?
  end
end
