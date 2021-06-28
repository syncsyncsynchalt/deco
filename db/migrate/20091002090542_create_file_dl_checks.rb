class CreateFileDlChecks < ActiveRecord::Migration
  def self.up
    create_table :file_dl_checks do |t|
      t.integer :receiver_id
      t.integer :attachment_id
      t.integer :download_flg

      t.timestamps
    end
  end

  def self.down
    drop_table :file_dl_checks
  end
end
