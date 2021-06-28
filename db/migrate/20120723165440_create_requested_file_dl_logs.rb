class CreateRequestedFileDlLogs < ActiveRecord::Migration
  def change
    create_table :requested_file_dl_logs do |t|
      t.integer :requested_attachment_id

      t.timestamps
    end
  end
end
