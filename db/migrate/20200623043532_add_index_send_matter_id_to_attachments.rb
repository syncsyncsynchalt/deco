class AddIndexSendMatterIdToAttachments < ActiveRecord::Migration[5.1]
  def change
    add_index :attachments, [:send_matter_id, :id], {:name => 'attachments_index_keys_1'}
    add_index :attachments, [:id, :send_matter_id], {:name => 'attachments_index_keys_2'}
    add_index :attachments, [:relayid], {:name => 'attachments_index_keys_3'}
    add_index :attachments, [:size, :created_at, :name, :send_matter_id, :id], {:name => 'attachments_index_keys_4'}
  end
end
