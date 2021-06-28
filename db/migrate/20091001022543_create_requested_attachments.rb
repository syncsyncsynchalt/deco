class CreateRequestedAttachments < ActiveRecord::Migration
  def self.up
    create_table :requested_attachments do |t|
      t.integer :requested_matter_id
      t.string :name
      t.integer :size
      t.string :content_type
      t.integer :download_flg
      t.string :relayid

      t.timestamps
    end
  end

  def self.down
    drop_table :requested_attachments
  end
end
