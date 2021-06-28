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
class TopController < ApplicationController
  before_filter :authorize
  before_filter :load_env
  before_filter :vacuum_file_for_file_exchange
  before_filter :vacuum_data_for_file_exchange
  def index
    session[:site_category] = nil
    @announcements =
        Announcement
        .order('updated_at desc')
    if @announcements
    end
    @content_frames = ContentFrame
        .where(:master_frame => 0)
        .order('content_frame_order')
  end
end
