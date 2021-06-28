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
class AddressBooksController < ApplicationController
  before_action :authorize, :load_env
  layout "user_management"

  def index_sub
    index()
    @address_books =
      @address_books
      .per(8)
    render :layout => 'sub'
  end

  def index_sub_result
=begin
#    @recipient_number = params[:recipient_number]
    @conditions = params[:conditions]
    if @conditions[:search_select].present?
      if @conditions[:search_text].present?
        @address_books = AddressBook.where("user_id = ? AND #{@conditions[:search_select]} LIKE ? ", current_user.id, "%#{@conditions[:search_text]}%").order("#{@conditions[:sort_select_1]} #{t("views.sort_value.#{@conditions[:sort_select_2]}")}").page params[:page]
      else
        @address_books = AddressBook.where("user_id = ? AND ( #{@conditions[:search_select]} = '' OR #{@conditions[:search_select]} IS NULL )", current_user.id).order("#{@conditions[:sort_select_1]} #{t("views.sort_value.#{@conditions[:sort_select_2]}")}").page params[:page]
      end
    else
      @address_books = AddressBook.where("user_id = ? ", current_user.id).order("#{@conditions[:sort_select_1]} #{t("views.sort_value.#{@conditions[:sort_select_2]}")}").page params[:page]
    end
=end
    index_sub()
  end


  def index_result
=begin
    @conditions = params[:conditions]
    if @conditions[:search_select].present?
      if @conditions[:search_text].present?
        @address_books = AddressBook.where("user_id = ? AND #{@conditions[:search_select]} LIKE ? ", current_user.id, "%#{@conditions[:search_text]}%").order("#{@conditions[:sort_select_1]} #{t("views.sort_value.#{@conditions[:sort_select_2]}")}").page params[:page]
      else
        @address_books = AddressBook.where("user_id = ? AND ( #{@conditions[:search_select]} = '' OR #{@conditions[:search_select]} IS NULL )", current_user.id).order("#{@conditions[:sort_select_1]} #{t("views.sort_value.#{@conditions[:sort_select_2]}")}").page params[:page]
      end
    else
      @address_books = AddressBook.where("user_id = ? ", current_user.id).order("#{@conditions[:sort_select_1]} #{t("views.sort_value.#{@conditions[:sort_select_2]}")}").page params[:page]
    end
=end
    index()
  end

  def edit_result
    @recipient_number = params[:recipient_number]
    @address_book = AddressBook.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to :action => "index"
  end

  def new_result
    @address_book = AddressBook.new
  end

  def destroy_result
    @address_book = AddressBook.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to :action => "index"
  end

  # GET /address_books
  # GET /address_books.json
  def index
    params[:conditions] ||= Hash.new
    where_strs = Array.new
    where_vals = Hash.new
    order_values = Array.new
    order_value = Array.new

    if params[:conditions][:search_text].present?
      case params[:conditions][:search_select]
      when 'organization', 'name', 'email'
        where_strs << "#{params[:conditions][:search_select]} LIKE :where_val"
        where_vals[:where_val] = "%#{ActiveRecord::Base.send(:sanitize_sql_like, params[:conditions][:search_text])}%"
      else
      end
    end

    case params[:conditions][:sort_select_1]
    when 'organization', 'name', 'email'
      order_value << params[:conditions][:sort_select_1]
    else
      order_value << "email"
    end
    params[:conditions][:sort_select_1] ||= 'email'
    case params[:conditions][:sort_select_2]
    when 'ASC', 'DESC', 'asc', 'desc'
      order_value << t("views.sort_value.#{params[:conditions][:sort_select_2]}")
    else
      order_value << "asc"
    end
    params[:conditions][:sort_select_2] ||= 'asc'
    order_values << order_value.join(" ")

    @address_books =
      current_user
      .address_books
      .where(where_strs.join(" AND "), where_vals)
      .order(order_values.join(", "))
      .page(params[:page])
#    @address_books = AddressBook.all.page params[:page]

    respond_to do |format|
      format.js
      format.html # index.html.erb
      format.json { render json: @address_books }
    end
  end

  # GET /address_books/1
  # GET /address_books/1.json
  def show
    @address_book = AddressBook.find(params[:id])
    @permit_flg = 0
    if @address_book.present? &&
        @address_book.user_id.to_i == current_user.id
      @permit_flg = 1
    end
    if @permit_flg == 1
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @address_book }
      end
    else
      redirect_to :action => :index
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to :action => "index"
  end

  # GET /address_books/new
  # GET /address_books/new.json
  def new
    @address_book = AddressBook.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @address_book }
    end
  end

  # GET /address_books/1/edit
  def edit
    @address_book = AddressBook.find(params[:id])
    @permit_flg = 0
    if @address_book.present? &&
        @address_book.user_id.to_i == current_user.id
      @permit_flg = 1
    end
    if @permit_flg == 1
      respond_to do |format|
        format.html # edit.html.erb
        format.json { render json: @address_book }
      end
    else
      redirect_to :action => :index
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to :action => "index"
  end

  # POST /address_books
  # POST /address_books.json
  def create
    @address_book = AddressBook.new(address_books_params(params[:address_book]))
    @address_book.user_id = session[:user_id] unless session[:user_id].blank?
    respond_to do |format|
      if @address_book.save
        format.html { redirect_to @address_book, notice: t("address_books.create.message") }
        format.json { render json: @address_book, status: :created, location: @address_book }
      else
        format.html { render action: "new" }
        format.json { render json: @address_book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /address_books/1
  # PUT /address_books/1.json
  def update
    @address_book = AddressBook.find(params[:id])
    @permit_flg = 0
    if @address_book.present? &&
        @address_book.user_id.to_i == current_user.id
      @permit_flg = 1
    end
    if @permit_flg == 1
      respond_to do |format|
        if @address_book.update_attributes(address_books_params(params[:address_book]))
#          format.html { redirect_to '/address_books/index_result/?recipient_address=1', notice: 'Address book was successfully updated.' }
          format.html { redirect_to @address_book, notice: t("address_books.update.message") }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @address_book.errors, status: :unprocessable_entity }
        end
      end
    else
      flash[:notice] = "不正なアクセスです。"
      redirect_to :action => :index
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to :action => "index"
  end

  # DELETE /address_books/1
  # DELETE /address_books/1.json
  def destroy
    @address_book = AddressBook.find(params[:id])
    @permit_flg = 0
    if @address_book.present? &&
        @address_book.user_id.to_i == current_user.id
      @permit_flg = 1
    end
    if @permit_flg == 1
      @address_book.destroy

      respond_to do |format|
        format.html { redirect_to address_books_url }
        format.json { head :no_content }
      end
    else
      flash[:notice] = "不正なアクセスです。"
      redirect_to :action => :index
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to :action => "index"
  end

  private

  def address_books_params(post_params)
    post_params.permit(
      :master_frame, :organization, :name, :email, :notes
    )
  end
end
