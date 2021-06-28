class AddIndexAttachmentIdToFileDlChecks < ActiveRecord::Migration[5.1]
  def change
    add_index :file_dl_checks, [:receiver_id, :attachment_id, :id, :download_flg], {:name => 'file_dl_checks_index_keys_1'}
    add_index :file_dl_checks, [:attachment_id, :receiver_id, :id, :download_flg], {:name => 'file_dl_checks_index_keys_2'}
    add_index :file_dl_checks, [:id, :receiver_id, :attachment_id, :download_flg], {:name => 'file_dl_checks_index_keys_3'}
  end
end
