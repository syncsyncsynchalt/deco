class AddIndexRequestMatterIdToRequestedMatters < ActiveRecord::Migration[5.1]
  def change
    add_index :requested_matters, [:request_matter_id, :id, :name, :mail_address], {:name => 'requested_matters_index_keys_1'}
    add_index :requested_matters, [:id, :request_matter_id, :name, :mail_address], {:name => 'requested_matters_index_keys_2'}
    add_index :requested_matters, [:url], {:name => 'requested_matters_index_keys_3'}
    add_index :requested_matters, [:url_operation], {:name => 'requested_matters_index_keys_4'}
  end
end
