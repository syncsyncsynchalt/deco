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

class FileRequestController < ApplicationController
  protect_from_forgery :except => [:upload]
  before_filter :load_env
  before_filter :authorize

  # 入力フォーム
  def index
    session[:site_category] = nil
    @request_matter = RequestMatter.new
    @requested_matter = RequestedMatter.new
    @requested_attachement = RequestedAttachment.new

    respond_to do |format|
      format.html
      format.xml { render :xml => @request_file }
    end
  end

  # 依頼内容作成
  def create
    recipients = Hash.new

    ActiveRecord::Base.transaction do
      @request_matter = RequestMatter.new(params[:request_matter])
      params[:requested_matter].each{ |key, value|
        @requested_matter = RequestedMatter.new(value)
        @requested_matter.request_matter = @request_matter
        @requested_matter.url = generate_random_strings(@requested_matter.name)
        @requested_matter.send_password =
            generate_random_strings(@requested_matter.mail_address).slice(1,8)
        @requested_matter.save!

        recipients[@requested_matter.id] = [ @requested_matter.mail_address,
                                             @requested_matter.name,
                                             @requested_matter.url,
                                             @requested_matter.send_password ]
      }

      unless @request_matter.save!
        render :action => 'index'
      end
    end

    session[:request_matter_id] = @request_matter.id

    flash[:notice] = 'ファイル依頼を完了しました。'
    redirect_to :action => 'result'

    recipients.each{ |key, value|
      full_url = "http://" + $app_env['URL'] + "/requested_file_send/login/" +
                 value[2]

      @mail = Notification.deliver_request_report(@request_matter,
                                         value[1], value[0],
                                         full_url, value[3],
                                         $app_env['REQUEST_PERIOD'].to_i)
    }

    req_url = "http://" + $app_env['URL'] + "/requested_file_send/login/"
    @requested_matters = @request_matter.requested_matters
    @mail = Notification.deliver_request_copied_report(@request_matter,
                                         @requested_matters, req_url,
                                         $app_env['REQUEST_PERIOD'].to_i)
  end

  def result
    @request_matter = RequestMatter.find(session[:request_matter_id])
    @requested_matters =
    RequestedMatter.find_all_by_request_matter_id(session[:request_matter_id])
  end
end
