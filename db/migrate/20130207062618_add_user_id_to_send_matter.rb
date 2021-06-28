class AddUserIdToSendMatter < ActiveRecord::Migration[4.2]
  def change
    add_column(:send_matters, :user_id, :string)
  end
end
