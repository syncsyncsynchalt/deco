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
module ApplicationHelper
  include Nmt
  def show_file_size(attachment)
    html =''
    if attachment.size >= (1024*1024)
      html << "#{(attachment.size/1024/1024).round}MB"
    elsif attachment.size >= 1024 && attachment.size < (1024*1024)
      html << "#{(attachment.size/1024).round}KB"
    else
      html << "#{(attachment.size).round}B"
    end
    return html
  end

  def get_receivers(send_matter_id,item)
    receivers = Receiver.where(:send_matter_id => send_matter_id)
    tmp_receivers = Hash.new
    tmp_receivers[:name] = Array.new
    tmp_receivers[:mail_address] = Array.new
    unless receivers.blank?
      receivers.each do |receiver|
        tmp_receivers[:name].push receiver.name
        tmp_receivers[:mail_address].push receiver.mail_address
      end
    end
    return tmp_receivers[item.to_sym]
  end

  def get_requested_matters_info(request_matter_id)
    requested_matters = RequestedMatter.where(:request_matter_id => request_matter_id)
    tmp_info = Hash.new
    info = Array.new
    tmp_info[:name] = Array.new
    tmp_info[:mail_address] = Array.new
    unless requested_matters.blank?
      requested_matters.each do |requested_matter|
        tmp_info[:name].push requested_matter.name
        tmp_info[:mail_address].push requested_matter.mail_address
        info.push [requested_matter.id, requested_matter.name, requested_matter.mail_address]
      end
    end
    return info
  end
end
