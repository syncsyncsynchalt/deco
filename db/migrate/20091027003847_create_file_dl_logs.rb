class CreateFileDlLogs < ActiveRecord::Migration
  def self.up
    create_table :file_dl_logs do |t|
      t.integer :file_dl_check_id

      t.timestamps
    end
  end

  def self.down
    drop_table :file_dl_logs
  end
end
