class CreateReceivers < ActiveRecord::Migration
  def self.up
    create_table :receivers do |t|
      t.integer :send_matter_id
      t.string :name
      t.string :mail_address
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :receivers
  end
end
