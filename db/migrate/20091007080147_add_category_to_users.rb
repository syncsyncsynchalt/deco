class AddCategoryToUsers < ActiveRecord::Migration
  def self.up
    add_column(:users, :category, :integer)
  end

  def self.down
    remove_column(:users, :category)
  end
end
