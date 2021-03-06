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
class ContentController < ApplicationController
  def load
    @items = Array.new
    @master_frame = params[:id]
    @content_items =
        ContentItem
        .where(:master_frame => @master_frame)
    @content_items.each.with_index do |content_item, count|
      @items.push(pickup_content_item(content_item))
    end
    @self_frame = ContentFrame.find(@master_frame)
    @title = @self_frame.title
    if @self_frame.master_frame == 0
      if @self_frame.expression_flag == 1
        @content_frames =
            ContentFrame
            .where(:master_frame => @self_frame.id)
      else
        redirect_to :controller => :top
      end
    else
      @content_frames =
          ContentFrame
          .where(:master_frame => @self_frame.master_frame)
      if @content_frames.length > 0
        @parent_frame = ContentFrame.find(@self_frame.master_frame)
 
        if @parent_frame.expression_flag == 1
          @title = "<a href=\"" + url_for(:controller => :content, :action => :load, :id => @parent_frame.id.to_s) + 
              "\">" + @parent_frame.title + "</a>" + " > " + @self_frame.title
        else
          redirect_to :controller => :top
        end
      end
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to :controller => :top
  end
end
