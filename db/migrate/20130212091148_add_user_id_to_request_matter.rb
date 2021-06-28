class AddUserIdToRequestMatter < ActiveRecord::Migration
  def change
    add_column(:request_matters, :user_id, :string)
  end
end
