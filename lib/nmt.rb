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
module Nmt
  def generate_random_strings(string)
    seed = ''
    seed = generate_random_string_values(string, 100)
    return Digest::SHA1.hexdigest(seed)
  end

  def generate_random_string_values(string, length = 100)
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    return Array.new(length.to_i){chars[rand(chars.size)]}.join 
  end

  def original_paginate(controller, action, page, total_page, w_in, w_out)
    string = ""
    if page == nil or total_page == nil or w_in == nil or w_out == nil
      string = "miss some paramater."
    else
      if page.to_i == 1
        string = string + "<< < "
      else
        string = string + "<a href=\"" +
                 url_for(:controller => controller,
                         :action => action,
                         :id => 1) +
                 "\"><<</a> "
        string = string + "<a href=\"" +
                 url_for(:controller => controller, :action => action, :id => page.to_i - 1) +
                 "\"><</a> "
      end

      if total_page.to_i <= w_in.to_i * 2 + 1
        p_c_s = 1
      elsif page.to_i > total_page.to_i - w_in.to_i
        p_c_s = total_page.to_i - w_in.to_i * 2
      elsif page.to_i <= w_in.to_i + 1
        p_c_s = 1
      else
        p_c_s = page.to_i - w_in.to_i
      end

      p_c_e = total_page.to_i
      if total_page.to_i <= w_in.to_i * 2 + 1
        p_c_e = total_page.to_i
      elsif page.to_i <= w_in.to_i
        p_c_e = w_in.to_i * 2 + 1
      elsif total_page.to_i <= page.to_i + w_in.to_i
        p_c_e = total_page.to_i
      else
        p_c_e = page.to_i + w_in.to_i
      end

      if p_c_s > 1
        if p_c_s <= w_out.to_i
          p_l_e = p_c_s - 1
        else
          p_l_e = w_out.to_i
        end
        1.upto(p_l_e) do |n|
          if page.to_i == n
            string = string + n.to_s + " "
          else
#                 /#{controller}/#{action}" +
            string = string + "<a href=\"" +
                     url_for(:controller => controller, :action => action, :id => n) +
                     "\">#{n.to_s}</a> "
          end
        end
        if p_c_s - 1 > w_out.to_i
          string = string + '... '
        end
      end

      p_c_s.upto(p_c_e) do |n|
        if page.to_i == n
          string = string + n.to_s + " "
        else
          string = string +
                   "<a href=\"" +
                   url_for(:controller => controller, :action => action, :id => n) +
                   "\">#{n}</a> "
        end
      end

      if total_page.to_i - p_c_e >= 1
        if total_page.to_i - p_c_e > w_out.to_i
          string = string + '... '
        end
        if total_page.to_i - p_c_e < w_out.to_i
          p_r_s = p_c_e
        else
          p_r_s = total_page.to_i - w_out.to_i + 1
        end
        p_r_s.upto(total_page.to_i) do |n|
          if page.to_i == n
            string = string + n.to_s + " "
          else
            string = string +
                     "<a href=\"" +
                     url_for(:controller => controller, :action => action, :id => n) +
                     "\">#{n}</a> "
          end
        end
      end

      if page.to_i == total_page.to_i
        string = string + '> >>'
      else
        string = string +
         "<a href=\"" +
         url_for(:controller => controller, :action => action, :id => page.to_i + 1) +
         "\">></a> "
        string = string +
         "<a href=\"" +
         url_for(:controller => controller, :action => action, :id => page.to_i + 1) +
         "\">>></a>"
      end
    end

    return string
  end

  def pickup_content_item(content_item)
    #content_item = ContentItem.new(data)
    #content_item = data
    case content_item.category when 1
      string = "<h3>" + content_item.string1 + "</h3>"
    when 2
      if content_item.flg.to_i == 1
        string = content_item.text1.gsub(/\r\n|\r|\n/,"<br>")
      else
        string = "<fieldset>" + content_item.text1 + "</fieldset>"
      end
    when 3
      string = "<img src=\"" +
               url_for(:controller => :create_images,
                       :action => :content_items,
                       :id => content_item.id.to_s) +
               "\">"
    when 4
      string_option = ""
      if content_item.flg.to_i == 1
        string_option = " target=\"_blank\""
      end
      string = "<a href=\"" + content_item.url + "\"" +
               string_option + ">" +
               content_item.string1 + "<\/a>"
    when 5
      string_option = ""
      if content_item.flg.to_i == 1
        string_option = " target=\"_blank\""
      end
      string = "<a href=\"" + content_item.url +
               "\"" + string_option + ">" +  
               "<img src=\"" +
               url_for(:controller => :create_images,
                       :action => :content_items,
                       :id => content_item.id.to_s) +
               "\" border=0>" + "<\/a>"
    when 7
      string = "<div class=\"center\">" +
        "<font color=\"#778899\">Powered by</font> " +
        "<a href=\"http\:\/\/deco-project.org\">" +
        "<img src=\"" +
               url_for(:controller => :assets,
                       :action => :common) +"/deco_s2.jpg\" alt=\"powerd by DECO\" " +
        "align=\"bottom\" style=\"vertical-align\: middle\;\" border=0>" +
        "</a></div>"
    end

    return string
  end

  def get_port
    if $app_env['ENABLE_SSL'].to_i == 1
      port = "https"
    else
      port = "http"
    end
    return port
  end
end
