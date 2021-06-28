class CreateAppEnvs < ActiveRecord::Migration[4.2]
  def change
    create_table :app_envs do |t|
      t.string :key
      t.string :value
      t.string :note
      t.integer :category

      t.timestamps
    end
  end
end
