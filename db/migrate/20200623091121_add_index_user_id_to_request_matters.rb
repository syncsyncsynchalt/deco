class AddIndexUserIdToRequestMatters < ActiveRecord::Migration[5.1]
  def change
    add_index :request_matters, [:user_id, :id, :name, :mail_address], {:name => 'request_matters_index_keys_1'}
    add_index :request_matters, [:user_id, :id, :mail_address, :name], {:name => 'request_matters_index_keys_2'}
    add_index :request_matters, [:id, :name, :mail_address], {:name => 'request_matters_index_keys_3'}
    add_index :request_matters, [:id, :mail_address, :name], {:name => 'request_matters_index_keys_4'}
    add_index :request_matters, [:url], {:name => 'request_matters_index_keys_5'}
  end
end
