class AddCategoryToAppEnvs < ActiveRecord::Migration
  def self.up
    add_column(:app_envs, :category, :integer)
  end

  def self.down
    remove_column(:app_envs, :category)
  end
end
