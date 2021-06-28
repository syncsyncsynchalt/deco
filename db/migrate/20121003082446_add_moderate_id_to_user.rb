class AddModerateIdToUser < ActiveRecord::Migration
  def change
    add_column(:users, :moderate_id, :integer)
  end
end
