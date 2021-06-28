class ChangeSizeOnAttachmentTables < ActiveRecord::Migration[5.1]
  def up
    change_column :attachments, :size, :bigint
    change_column :requested_attachments, :size, :bigint
  end

  def down
    change_column :requested_attachments, :size, :integer
    change_column :attachments, :size, :integer
  end
end
