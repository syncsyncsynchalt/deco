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
  belongs_to :moderate
  has_many :address_books
  has_many :send_matters
  has_many :request_matters

  attr_accessor :password
#  attr_accessible :login, :password_digest
#  attr_accessor :password_digest
#  has_secure_password
  before_save :encrypt_password

  validates_uniqueness_of :login, :message => '同じユーザIDが既に登録されています'
  validates_presence_of :name, :if => :password_required?, :message => 'ユーザ名を入力してください'
  validates_presence_of :email, :if => :password_required?, :message => 'メールアドレスを入力してください'
  validates_presence_of :password, :if => :password_required?, :message => 'パスワードを入力してください'
  validates_presence_of :password_confirmation, :if => :password_required?, :message => 'パスワード(確認)を入力してください'
  validates_length_of :password, :within => 4..40, :if => :password_required?, :message => 'パスワードは4～40文字です'
  validates_confirmation_of :password, :if => :password_required?, :message => 'パスワードが一致しません'

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
