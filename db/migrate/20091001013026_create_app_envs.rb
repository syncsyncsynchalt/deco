class CreateAppEnvs < ActiveRecord::Migration
  def self.up
    create_table :app_envs do |t|
      t.string :key
      t.string :value

      t.timestamps
    end
  end

  def self.down
    drop_table :app_envs
  end
end
