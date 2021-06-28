class CreateFileDlChecks < ActiveRecord::Migration
  def change
    create_table :file_dl_checks do |t|
      t.integer :receiver_id
      t.integer :attachment_id
      t.integer :download_flg

      t.timestamps
    end
  end
end
