class CreateRequestedMatters < ActiveRecord::Migration
  def change
    create_table :requested_matters do |t|
      t.integer :request_matter_id
      t.string :name
      t.string :mail_address
      t.string :send_password
      t.string :receive_password
      t.integer :download_check
      t.text :message
      t.integer :file_life_period
      t.string :url
      t.integer :status
      t.string :relayid
      t.integer :password_notice
      t.datetime :file_up_date
      t.string :url_operation

      t.timestamps
    end
  end
end
