class AddIndexSendMatterIdToReceivers < ActiveRecord::Migration[5.1]
  def change
    add_index :receivers, [:send_matter_id, :name, :mail_address, :id], {:name => 'receivers_index_keys_1'}
    add_index :receivers, [:send_matter_id, :mail_address, :name, :id], {:name => 'receivers_index_keys_2'}
    add_index :receivers, [:id, :send_matter_id, :mail_address, :name], {:name => 'receivers_index_keys_3'}
    add_index :receivers, [:id, :send_matter_id, :name, :mail_address], {:name => 'receivers_index_keys_4'}
    add_index :receivers, [:url], {:name => 'receivers_index_keys_5'}
  end
end
