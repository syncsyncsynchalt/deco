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

require 'csv'

IMPORT_FILE_SIZE_LIMIT = 1024*1024  # インポートファイル最大容量(Byte)
RECEIVER_NAME_COLUMN = 0  #CSVファイル中の受取人名の列番号

class ReceiverListImportController < ApplicationController
  before_action :authorize
  before_action :load_env
  #インポート・ファイル選択画面
  def index
    case params[:type]
    when "file_send"
      @title = "受取人"
    when "file_request"
      @title = "送信者"
    end

    respond_to do |format|
      format.html
      format.xml { render :xml => @send_file }
    end
  end

  # ファイル読み込み時の処理
  def show
    begin
      file = params[:file_data][:name]
      if file == ""
        render :nothing => true;
        return
      end

      file_name = file.original_filename
      file_size = file.size

      perms = ['.csv']
      if !perms.include?(File.extname(file_name).downcase)
        @error_message = "ファイルの拡張子が.csvではありません。"
        render :action => "show"
        return
      end

      if file.size > IMPORT_FILE_SIZE_LIMIT
        @error_message = "読み込めるCSVファイルは" + 
          ("#{IMPORT_FILE_SIZE_LIMIT}".to_i / (1024*1024)).to_s + "MBまでです。"
        render :action => "show"
        return
      end

      @file = params[:file_data][:name]
      @randam_filename =
          generate_random_string_values(rand(10000).to_s).slice(1,12)
      begin
        if @file
          File.open(@params_app_env['FILE_DIR'] + "/#{@randam_filename}.csv", "wb") do |f|
            f.binmode
            f.write(@file.read)
          end
        end

#        csv = CSV::StringReader.new(file.read.toutf8)
#        csv = CSV.parse(file.read)
        csv_array = Array.new

        CSV.foreach(@params_app_env['FILE_DIR'] + "/#{@randam_filename}.csv", :encoding =>  "SJIS:UTF-8") do |row|
          csv_array.push row 
        end
        if File.exist?(@params_app_env['FILE_DIR'] + "/#{@randam_filename}.csv")
          File.delete(@params_app_env['FILE_DIR'] + "/#{@randam_filename}.csv")
        end
      rescue
        if @randam_filename.present?
          if File.exist?(@params_app_env['FILE_DIR'] + "/#{@randam_filename}.csv")
            File.delete(@params_app_env['FILE_DIR'] + "/#{@randam_filename}.csv")
          end
        end
        @error_message = "CSVファイルの形式が不正です。読み込みを中断しました。"
      end
      @list = pad_row(delete_repeated_row(csv_array, RECEIVER_NAME_COLUMN))
      
      case params[:type]
      when "file_send"
        @div_id = "receiver_info_input"
        @model_name = "receiver"
        @id_name = "receiver_form"
        @text = "ファイル受取人"
      when "file_request"
        @div_id = "requested_matter_info_input"
        @model_name = "requested_matter"
        @id_name = "receiver_form"
        @text = "ファイル送信者"
      end
    rescue
      @error_message = "CSVファイルの形式が不正です。読み込みを中断しました。"
    end

    render :action => "show"
  end

  # 指定列の内容が重複するレコードの削除
  def delete_repeated_row(input_array, column_number)
    column_array = Array.new
    input_array.each do |row|
      column_array.push row[column_number]
    end

    repeated_row_index = Array.new
    column_array.each_with_index do |column, i|
      if column_array.index(column) != column_array.rindex(column) &&
          i != column_array.index(column)
        repeated_row_index.push i
      end
    end

    output_array = Array.new
    input_array.each_with_index do |row, i|
      unless repeated_row_index.include?(i)
        output_array.push row
      end
    end

    return output_array
  end

  #最大列数にpadding
  def pad_row(input_array)
    size = 0
    input_array.each do |row|
      if row.size > size
        size = row.size
      end
    end
    
    output_array = Array.new
    input_array.each do |row|
      output_array.push row.fill((row.size)..(size-1)){""}
    end

    return output_array
  end

  # iframeでsrc属性を指定しないとSSLでセキュリティ警告が発生することへの対応
  # http://support.microsoft.com/kb/261188/ja
  def dummy_action
    render :plain => ''
  end
end
