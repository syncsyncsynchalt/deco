class AddIndexFileDlCheckIdToFileDlLogs < ActiveRecord::Migration[5.1]
  def change
    add_index :file_dl_logs, [:file_dl_check_id, :created_at, :id], {:name => 'file_dl_logs_index_keys_1'}
    add_index :file_dl_logs, [:file_dl_check_id, :id, :created_at], {:name => 'file_dl_logs_index_keys_2'}
  end
end
