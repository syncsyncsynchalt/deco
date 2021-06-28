class AddUserIdToSendMatter < ActiveRecord::Migration
  def change
    add_column(:send_matters, :user_id, :string)
  end
end
