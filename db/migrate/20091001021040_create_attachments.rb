class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.integer :send_matter_id
      t.string :name
      t.integer :size
      t.string :content_type
      t.string :relayid

      t.timestamps
    end
  end

  def self.down
    drop_table :attachments
  end
end
