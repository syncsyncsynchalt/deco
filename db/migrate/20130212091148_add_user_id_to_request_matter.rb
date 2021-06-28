class AddUserIdToRequestMatter < ActiveRecord::Migration[4.2]
  def change
    add_column(:request_matters, :user_id, :string)
  end
end
