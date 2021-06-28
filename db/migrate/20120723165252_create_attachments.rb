class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.integer :send_matter_id
      t.string :name
      t.integer :size
      t.string :content_type
      t.string :relayid
      t.string :virus_check
      t.string :file_save_pass

      t.timestamps
    end
  end
end
