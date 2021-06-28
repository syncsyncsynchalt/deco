class CreateSendMatters < ActiveRecord::Migration
  def change
    create_table :send_matters do |t|
      t.string :name
      t.string :mail_address
      t.string :receive_password
      t.integer :password_notice
      t.integer :download_check
      t.text :message
      t.integer :file_life_period
      t.string :url
      t.integer :status
      t.string :relayid

      t.timestamps
    end
  end
end
