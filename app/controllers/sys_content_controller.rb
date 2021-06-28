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
class SysContentController < ApplicationController
  layout 'system_admin'
  before_filter :check_ip_for_administrator, :administrator_authorize,
                :initialize_value_for_operation
  def index
    session[:section_title] = 'コンテンツ管理'
    session[:target_for_back] = 'index'
    session[:target_for_back_id] = nil

    @top_content_frames = ContentFrame.find(:all,
            :conditions => { :master_frame => 0 },
			:order => "content_frame_order")
    @stat = 0
    if @top_content_frames.length < 4
      ActiveRecord::Base.transaction do
        (@top_content_frames.length + 1).upto(4) do |i|
          @content_frame = ContentFrame.new()
          @content_frame.title = "初期値 - " + i.to_s
          @content_frame.content_frame_order = i
          @content_frame.master_frame = 0
          @content_frame.save!
          @stat = 9
        end
      end
      @top_content_frames = ContentFrame.find(:all,
            :conditions => { :master_frame => 0 },
			:order => "content_frame_order")
    end

    if @stat == 9
      flash[:notice] = "初期化しました"
    end
  end

  def edit_page
    @items = Array.new
    session[:target_for_back] = 'index'
    session[:target_for_back_id] = nil
    @master_frame = params[:id]
    @content_frame = ContentFrame.find(@master_frame)
    @content_items = ContentItem.find(:all,
            :conditions => { :master_frame => @master_frame })

    unless @content_frame.master_frame == 0
      @parent_frame = ContentFrame.find(@content_frame.master_frame)
    end

    @content_items.each.with_index do |content_item, count|
      @items.push(pickup_content_item(content_item))
    end
  end

  def edit_item
    if params[:id]
      @content_item = ContentItem.find(params[:id])
      @edit_type = "update"
    else
      @content_item = ContentItem.new(params[:content_item])
      @edit_type = "new"
    end

    session[:target_for_back] = 'edit_page'
    session[:target_for_back_id] = @content_item.master_frame
  end

  def delete_item
    ActiveRecord::Base.transaction do
      @content_item = ContentItem.find(params[:id])
      @master_frame = @content_item.master_frame
      @content_item_order = @content_item.content_item_order
      @content_item.destroy
      @content_item.save!

      @content_items = ContentItem.find(:all, 
              :conditions => ["master_frame = ? AND content_item_order > ?",
                @master_frame, @content_item_order] )
      @content_items.each do |content_item|
        content_item.content_item_order = content_item.content_item_order - 1
        content_item.save!
      end
    end

    session[:target_for_back] = 'edit_page'
    session[:target_for_back_id] = @master_frame

    flash[:notice] = '[ID:' + @content_item.id.to_s + '] を削除しました。'
    render :action => "message"
  end

  def register_item
    if params[:content_item][:id]
      @content_item = ContentItem.find(params[:content_item][:id])
    else
      @content_item = ContentItem.new(params[:content_item])
      @content_items = ContentItem.find(:all,
              :conditions => { :master_frame => @content_item.master_frame })
      @content_item.content_item_order = @content_items.length + 1
    end

    session[:target_for_back] = 'edit_page'
    session[:target_for_back_id] = params[:content_item][:master_frame]

    @result = 0
    if (params[:content_item][:category]).to_i == 3 or
       (params[:content_item][:category]).to_i == 5
      if params[:image].present?
        @check_content_type = params[:image].content_type
        unless @check_content_type =~ /image/
          flash[:error] = '画像データではありません'
          @result = 1
        end
      else
        flash[:error] = '画像データがありません'
        @result = 1
      end
    end

    if @result == 0
      ActiveRecord::Base.transaction do
        @content_item.update_attributes(params[:content_item])
        if @content_item.category == 3 or
           @content_item.category == 5
          @content_item.image = params[:image].read
        end

        if @content_item.save!
          flash[:notice] = '編集しました。'
        else
          flash[:error] = '失敗'
        end
      end
    end
    render :action => "message"
  end

  # 子ページを追加
  def add_subpage
    master_frame_id = params[:id]
    @content_frames = ContentFrame.find(:all,
            :conditions => { :master_frame => master_frame_id })
    ActiveRecord::Base.transaction do
      @content_frame = ContentFrame.new()
      @content_frame.title = "新しいページ - " +
        (@content_frames.length + 1).to_s
      @content_frame.content_frame_order = @content_frames.length + 1
      @content_frame.master_frame = master_frame_id
      if @content_frame.save!
        flash[:notice] = 'ページを追加しました。'
      else
        flash[:error] = '失敗'
      end
    end
    render :action => "message"
  end

  def delete_page
    ActiveRecord::Base.transaction do
      @content_frame = ContentFrame.find(params[:id])
      @master_frame = @content_frame.master_frame
      @content_frame_order = @content_frame.content_frame_order
      @content_frame.destroy
      @content_frame.save!

      @content_frames = ContentFrame.find(:all, 
              :conditions => ["master_frame = ? AND content_frame_order > ?",
                @master_frame, @content_frame_order] )
      @content_frames.each do |content_frame|
        content_frame.content_frame_order =
          content_frame.content_frame_order - 1
        content_frame.save!
      end
    end

    session[:target_for_back] = 'index'
    session[:target_for_back_id] = nil

    flash[:notice] = '[ID:' + @content_frame.id.to_s + '] を削除しました。'
    render :action => "message"
  end

  def edit_title
    session[:target_for_back] = 'edit_page'
    session[:target_for_back_id] = params[:id]
    @content_frame = ContentFrame.find(params[:id])
  end

  def edit_description
    session[:target_for_back] = 'edit_page'
    session[:target_for_back_id] = params[:id]
    @content_frame = ContentFrame.find(params[:id])
  end

  def update_content_frame
    @content_frame = ContentFrame.find(params[:id])
    if @content_frame.update_attributes(params[:content_frame])
      flash[:notice] = '修正しました。'
    else
      flash[:error] = '失敗'
    end
    render :action => "message"
  end

  def show_image
    if params[:id].present?
      @content_item = ContentItem.find(params[:id])
      send_data @content_item.image
    end
  end
end
