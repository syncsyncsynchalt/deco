# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130213084332) do

  create_table "address_books", :force => true do |t|
    t.integer  "user_id"
    t.string   "from_email"
    t.string   "name"
    t.string   "email"
    t.string   "organization"
    t.string   "notes"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "announcements", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "app_envs", :force => true do |t|
    t.string   "key"
    t.string   "value"
    t.string   "note"
    t.integer  "category"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "attachments", :force => true do |t|
    t.integer  "send_matter_id"
    t.string   "name"
    t.integer  "size"
    t.string   "content_type"
    t.string   "relayid"
    t.string   "virus_check"
    t.string   "file_save_pass"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "content_frames", :force => true do |t|
    t.string   "title"
    t.integer  "content_frame_order"
    t.integer  "master_frame"
    t.text     "description"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "content_items", :force => true do |t|
    t.integer  "category"
    t.string   "string1"
    t.text     "text1"
    t.string   "url"
    t.integer  "flg"
    t.integer  "content_item_order"
    t.integer  "master_frame"
    t.binary   "image",              :limit => 16777215
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  create_table "file_dl_checks", :force => true do |t|
    t.integer  "receiver_id"
    t.integer  "attachment_id"
    t.integer  "download_flg"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "file_dl_logs", :force => true do |t|
    t.integer  "file_dl_check_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "moderaters", :force => true do |t|
    t.integer  "moderate_id"
    t.integer  "user_id"
    t.integer  "number"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "moderates", :force => true do |t|
    t.string   "name"
    t.integer  "route"
    t.integer  "type_flag"
    t.integer  "use_flag"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "receivers", :force => true do |t|
    t.integer  "send_matter_id"
    t.string   "name"
    t.string   "mail_address"
    t.string   "url"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "request_matters", :force => true do |t|
    t.string   "name"
    t.string   "mail_address"
    t.text     "message"
    t.string   "url"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "moderate_flag"
    t.integer  "moderate_result"
    t.datetime "sent_at"
    t.string   "user_id"
  end

  create_table "request_moderaters", :force => true do |t|
    t.integer  "request_moderate_id"
    t.integer  "moderater_id"
    t.integer  "user_id"
    t.integer  "user_name"
    t.integer  "number"
    t.text     "content"
    t.integer  "send_flag"
    t.integer  "result"
    t.string   "url"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "request_moderates", :force => true do |t|
    t.integer  "request_matter_id"
    t.integer  "moderater_id"
    t.string   "name"
    t.integer  "type_flag"
    t.integer  "result"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.datetime "moderated_at"
  end

  create_table "requested_attachments", :force => true do |t|
    t.integer  "requested_matter_id"
    t.string   "name"
    t.integer  "size"
    t.string   "content_type"
    t.integer  "download_flg"
    t.string   "relayid"
    t.string   "virus_check"
    t.string   "file_save_pass"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "requested_file_dl_logs", :force => true do |t|
    t.integer  "requested_attachment_id"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "requested_matters", :force => true do |t|
    t.integer  "request_matter_id"
    t.string   "name"
    t.string   "mail_address"
    t.string   "send_password"
    t.string   "receive_password"
    t.integer  "download_check"
    t.text     "message"
    t.integer  "file_life_period"
    t.string   "url"
    t.integer  "status"
    t.string   "relayid"
    t.integer  "password_notice"
    t.datetime "file_up_date"
    t.string   "url_operation"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "send_matters", :force => true do |t|
    t.string   "name"
    t.string   "mail_address"
    t.string   "receive_password"
    t.integer  "password_notice"
    t.integer  "download_check"
    t.text     "message"
    t.integer  "file_life_period"
    t.string   "url"
    t.integer  "status"
    t.string   "relayid"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "moderate_flag"
    t.integer  "moderate_result"
    t.datetime "sent_at"
    t.string   "user_id"
  end

  create_table "send_moderaters", :force => true do |t|
    t.integer  "send_moderate_id"
    t.integer  "moderater_id"
    t.integer  "user_id"
    t.integer  "user_name"
    t.integer  "number"
    t.text     "content"
    t.integer  "send_flag"
    t.integer  "result"
    t.string   "url"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "send_moderates", :force => true do |t|
    t.integer  "send_matter_id"
    t.integer  "moderate_id"
    t.string   "name"
    t.integer  "type_flag"
    t.integer  "result"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.datetime "moderated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "name"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.integer  "category"
    t.text     "note"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
    t.integer  "moderate_id"
    t.string   "from_organization_add"
    t.boolean  "to_organization_add",                     :default => false
  end

end
