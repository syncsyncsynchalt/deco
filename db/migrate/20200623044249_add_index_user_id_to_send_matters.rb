class AddIndexUserIdToSendMatters < ActiveRecord::Migration[5.1]
  def change
    add_index :send_matters, [:relayid], {:name => 'send_matters_index_keys_1'}
    add_index :send_matters, [:user_id, :id, :name, :mail_address], {:name => 'send_matters_index_keys_2'}
    add_index :send_matters, [:user_id, :id, :mail_address, :name], {:name => 'send_matters_index_keys_3'}
    add_index :send_matters, [:id, :name, :mail_address], {:name => 'send_matters_index_keys_4'}
    add_index :send_matters, [:id, :mail_address, :name], {:name => 'send_matters_index_keys_5'}
  end
end
