class CreateSendMatters < ActiveRecord::Migration
  def self.up
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

  def self.down
    drop_table :send_matters
  end
end
