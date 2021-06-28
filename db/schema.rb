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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20210301071616) do

  create_table "address_books", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.string "from_email"
    t.string "name"
    t.string "email"
    t.string "organization"
    t.string "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "announcements", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "title"
    t.text "body"
    t.integer "show_flg", default: 1
    t.timestamp "begin_at"
    t.timestamp "end_at"
    t.integer "body_show_flg", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "app_envs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "key"
    t.string "value"
    t.string "note"
    t.integer "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attachments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "send_matter_id"
    t.string "name"
    t.bigint "size"
    t.string "content_type"
    t.string "relayid"
    t.string "virus_check"
    t.string "file_save_pass"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["id", "send_matter_id"], name: "attachments_index_keys_2"
    t.index ["relayid"], name: "attachments_index_keys_3"
    t.index ["send_matter_id", "id"], name: "attachments_index_keys_1"
    t.index ["size", "created_at", "name", "send_matter_id", "id"], name: "attachments_index_keys_4"
  end

  create_table "content_frames", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "title"
    t.integer "content_frame_order"
    t.integer "master_frame"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "expression_flag"
  end

  create_table "content_items", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "category"
    t.string "string1"
    t.text "text1"
    t.string "url"
    t.integer "flg"
    t.integer "content_item_order"
    t.integer "master_frame"
    t.binary "image", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "file_dl_checks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "receiver_id"
    t.integer "attachment_id"
    t.integer "download_flg"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["attachment_id", "receiver_id", "id", "download_flg"], name: "file_dl_checks_index_keys_2"
    t.index ["id", "receiver_id", "attachment_id", "download_flg"], name: "file_dl_checks_index_keys_3"
    t.index ["receiver_id", "attachment_id", "id", "download_flg"], name: "file_dl_checks_index_keys_1"
  end

  create_table "file_dl_logs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "file_dl_check_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["file_dl_check_id", "created_at", "id"], name: "file_dl_logs_index_keys_1"
    t.index ["file_dl_check_id", "id", "created_at"], name: "file_dl_logs_index_keys_2"
  end

  create_table "moderaters", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "moderate_id"
    t.integer "user_id"
    t.integer "number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "moderates", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.integer "route"
    t.integer "type_flag"
    t.integer "use_flag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "receivers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "send_matter_id"
    t.string "name"
    t.string "mail_address"
    t.string "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["id", "send_matter_id", "mail_address", "name"], name: "receivers_index_keys_3"
    t.index ["id", "send_matter_id", "name", "mail_address"], name: "receivers_index_keys_4"
    t.index ["send_matter_id", "mail_address", "name", "id"], name: "receivers_index_keys_2"
    t.index ["send_matter_id", "name", "mail_address", "id"], name: "receivers_index_keys_1"
    t.index ["url"], name: "receivers_index_keys_5"
  end

  create_table "request_matters", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "mail_address"
    t.text "message"
    t.string "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "moderate_flag"
    t.integer "moderate_result"
    t.timestamp "sent_at"
    t.string "user_id"
    t.index ["id", "mail_address", "name"], name: "request_matters_index_keys_4"
    t.index ["id", "name", "mail_address"], name: "request_matters_index_keys_3"
    t.index ["url"], name: "request_matters_index_keys_5"
    t.index ["user_id", "id", "mail_address", "name"], name: "request_matters_index_keys_2"
    t.index ["user_id", "id", "name", "mail_address"], name: "request_matters_index_keys_1"
  end

  create_table "request_moderaters", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "request_moderate_id"
    t.integer "moderater_id"
    t.integer "user_id"
    t.integer "user_name"
    t.integer "number"
    t.text "content"
    t.integer "send_flag"
    t.integer "result"
    t.string "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "request_moderates", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "request_matter_id"
    t.integer "moderate_id"
    t.integer "moderater_id"
    t.string "name"
    t.integer "type_flag"
    t.integer "result"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.timestamp "moderated_at"
  end

  create_table "requested_attachments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "requested_matter_id"
    t.string "name"
    t.bigint "size"
    t.string "content_type"
    t.integer "download_flg"
    t.string "relayid"
    t.string "virus_check"
    t.string "file_save_pass"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["id", "requested_matter_id", "name", "size", "created_at"], name: "requested_attachments_index_keys_2"
    t.index ["requested_matter_id", "id", "name", "size", "created_at"], name: "requested_attachments_index_keys_1"
    t.index ["size", "created_at", "name", "requested_matter_id", "id"], name: "requested_attachments_index_keys_3"
  end

  create_table "requested_file_dl_logs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "requested_attachment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["requested_attachment_id", "created_at", "id"], name: "requested_file_dl_logs_index_keys_1"
    t.index ["requested_attachment_id", "id", "created_at"], name: "requested_file_dl_logs_index_keys_2"
  end

  create_table "requested_matters", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "request_matter_id"
    t.string "name"
    t.string "mail_address"
    t.string "send_password"
    t.string "receive_password"
    t.integer "download_check"
    t.text "message"
    t.integer "file_life_period"
    t.string "url"
    t.integer "status"
    t.string "relayid"
    t.integer "password_notice"
    t.datetime "file_up_date"
    t.string "url_operation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["id", "request_matter_id", "name", "mail_address"], name: "requested_matters_index_keys_2"
    t.index ["request_matter_id", "id", "name", "mail_address"], name: "requested_matters_index_keys_1"
    t.index ["url"], name: "requested_matters_index_keys_3"
    t.index ["url_operation"], name: "requested_matters_index_keys_4"
  end

  create_table "send_matters", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "mail_address"
    t.string "receive_password"
    t.integer "password_notice"
    t.integer "download_check"
    t.text "message"
    t.integer "file_life_period"
    t.string "url"
    t.integer "status"
    t.string "relayid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "moderate_flag"
    t.integer "moderate_result"
    t.timestamp "sent_at"
    t.string "user_id"
    t.index ["id", "mail_address", "name"], name: "send_matters_index_keys_5"
    t.index ["id", "name", "mail_address"], name: "send_matters_index_keys_4"
    t.index ["relayid"], name: "send_matters_index_keys_1"
    t.index ["user_id", "id", "mail_address", "name"], name: "send_matters_index_keys_3"
    t.index ["user_id", "id", "name", "mail_address"], name: "send_matters_index_keys_2"
  end

  create_table "send_moderaters", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "send_moderate_id"
    t.integer "moderater_id"
    t.integer "user_id"
    t.integer "user_name"
    t.integer "number"
    t.text "content"
    t.integer "send_flag"
    t.integer "result"
    t.string "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "send_moderates", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "send_matter_id"
    t.integer "moderate_id"
    t.string "name"
    t.integer "type_flag"
    t.integer "result"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.timestamp "moderated_at"
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "login"
    t.string "name"
    t.string "email"
    t.string "crypted_password", limit: 40
    t.string "salt", limit: 40
    t.integer "category"
    t.text "note"
    t.string "remember_token"
    t.datetime "remember_token_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "moderate_id"
    t.string "from_organization_add"
    t.boolean "to_organization_add", default: false
  end

end
