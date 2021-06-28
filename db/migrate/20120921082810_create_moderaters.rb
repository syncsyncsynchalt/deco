class CreateModeraters < ActiveRecord::Migration
  def change
    create_table :moderaters do |t|
      t.integer :moderate_id
      t.integer :user_id
      t.integer :number

      t.timestamps
    end
  end
end
