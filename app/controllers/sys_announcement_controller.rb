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
class SysAnnouncementController < ApplicationController
  layout 'system_admin'
  before_filter :check_ip_for_administrator, :administrator_authorize
  def index
    session[:section_title] = 'アナウンス管理'
    @announcements = Announcement.order('updated_at desc, id')
  end

  def create
    @announcement = Announcement.new(params[:announcement])
    if @announcement.save
      flash[:notice] = 'アナウンスを１件登録しました。'
    else
      flash[:error] = '失敗'
    end
    render :action => "message"
  end

  # edit
  def edit
    @announcement = Announcement.find(params[:id])
  end

  # update
  def update
    @announcement = Announcement.find(params[:id])
    if @announcement.update_attributes(params[:announcement])
      flash[:notice] = '「' + @announcement.title + '」 を修正しました。'
    else
      flash[:error] = '失敗'
    end
    render :action => "message"
  end

  # destroy
  def destroy
    @announcement = Announcement.find(params[:id])
    @announcement.destroy
    flash[:notice] = '「' + @announcement.title + '」 を削除しました。'
    render :action => "message"
  end

  def message
  end
end
