class AddIndexRequestedAttachmentIdToRequestedFileDlLogs < ActiveRecord::Migration[5.1]
  def change
    add_index :requested_file_dl_logs, [:requested_attachment_id, :created_at, :id], {:name => 'requested_file_dl_logs_index_keys_1'}
    add_index :requested_file_dl_logs, [:requested_attachment_id, :id, :created_at], {:name => 'requested_file_dl_logs_index_keys_2'}
  end
end
