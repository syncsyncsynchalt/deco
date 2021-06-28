class AddModerateIdToUser < ActiveRecord::Migration[4.2]
  def change
    add_column(:users, :moderate_id, :integer)
  end
end
