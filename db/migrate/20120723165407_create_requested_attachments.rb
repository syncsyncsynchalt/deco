class CreateRequestedAttachments < ActiveRecord::Migration
  def change
    create_table :requested_attachments do |t|
      t.integer :requested_matter_id
      t.string :name
      t.integer :size
      t.string :content_type
      t.integer :download_flg
      t.string :relayid
      t.string :virus_check
      t.string :file_save_pass

      t.timestamps
    end
  end
end
