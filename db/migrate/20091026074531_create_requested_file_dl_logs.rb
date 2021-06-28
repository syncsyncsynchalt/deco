class CreateRequestedFileDlLogs < ActiveRecord::Migration
  def self.up
    create_table :requested_file_dl_logs do |t|
      t.integer :requested_attachment_id

      t.timestamps
    end
  end

  def self.down
    drop_table :requested_file_dl_logs
  end
end
