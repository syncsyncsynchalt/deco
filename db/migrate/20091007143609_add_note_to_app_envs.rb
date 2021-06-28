class AddNoteToAppEnvs < ActiveRecord::Migration
  def self.up
    add_column(:app_envs, :note, :string)
  end

  def self.down
    remove_column(:app_envs, :note)
  end
end
