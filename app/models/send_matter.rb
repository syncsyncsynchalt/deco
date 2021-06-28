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
class SendMatter < ActiveRecord::Base
  has_many(:receivers)
  has_many(:attachments)
  has_one :send_moderate
  belongs_to :user

  scope :with_begin_date, ->(begin_date) {
    unless begin_date.blank?
      where(arel_table[:created_at].gteq(Date.parse(begin_date).to_s(:db)))
    end
  }
  scope :with_end_date, ->(end_date) {
    unless end_date.blank?
      where(arel_table[:created_at].lteq(Date.parse(end_date).to_s(:db)))
    end
  }
  scope :with_receivers, ->(select, text) {
    unless select.blank? || text.blank?
      receivers =Receiver.arel_table
      includes(:receivers).where(receivers[select.to_sym].matches('%'+text.to_s+'%'))
    end
  }
  scope :with_order, ->(sort_select_1, sort_select_2) {
    order(arel_table[sort_select_1.to_sym].__send__(sort_select_2))
  }
  scope :search_q, ->(user_id, conditions) {
    with_begin_date(conditions[:begin_date]).
    with_end_date(conditions[:nd_date]).
    with_receivers(conditions[:search_select], conditions[:search_text]).
    where(:user_id => user_id).
    with_order(conditions[:sort_select_1], conditions[:sort_select_2])
  }

  scope :with_select, ->(){
    send_matters = SendMatter.arel_table
    receivers =Receiver.arel_table
    select("receivers.name")
  }

  scope :test_q, ->() {
    send_matters = SendMatter.arel_table
    receivers =Receiver.arel_table
    col = [Receiver.arel_table[:name], SendMatter.arel_table[:created_at]]
    select(col).to_sql
#    send_ma#tters = SendMatter.arel_table
#    receivers = Receiver.arel_table
#    send_matters = send_matters.join(receivers).on(send_matters[:id].eq(receivers[:send_matter_id]))
#      joins(receivers).on(send_matters[:id].eq(receivers[:send_matter_id]))

#    send_matters = send_matters.select(receivers[:name].as())
#    select('name as OOOOOO').where("")
  }

  scope :date_range, lambda { |from, to| where("send_matters.created_at between ? and ?", from, to)}
  scope :search_text, lambda { |select, text| where("#{select} LIKE ?", '%'+text+'%')}

end
