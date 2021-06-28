class CreateFileDlLogs < ActiveRecord::Migration
  def change
    create_table :file_dl_logs do |t|
      t.integer :file_dl_check_id

      t.timestamps
    end
  end
end
