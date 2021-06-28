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

class SendMatter < ActiveRecord::Base
  has_many(:receivers)
  has_many(:attachments)
  validates_length_of :name, :mail_address, :receive_password,
                      :password_notice, :download_check, :message,
                      :file_life_period, :url, :status,
                      :relayid, :within => (0..1024)
end
