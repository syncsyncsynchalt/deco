class CreateRequestedMatters < ActiveRecord::Migration
  def self.up
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

      t.timestamps
    end
  end

  def self.down
    drop_table :requested_matters
  end
end
