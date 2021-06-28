class AddIndexRequestedMatterIdToRequestedAttachments < ActiveRecord::Migration[5.1]
  def change
    add_index :requested_attachments, [:requested_matter_id, :id, :name, :size, :created_at], {:name => 'requested_attachments_index_keys_1'}
    add_index :requested_attachments, [:id, :requested_matter_id, :name, :size, :created_at], {:name => 'requested_attachments_index_keys_2'}
    add_index :requested_attachments, [:size, :created_at, :name, :requested_matter_id, :id], {:name => 'requested_attachments_index_keys_3'}
  end
end
