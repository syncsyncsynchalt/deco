class CreateModerates < ActiveRecord::Migration[4.2]
  def change
    create_table :moderates do |t|
      t.string :name
      t.integer :route
      t.integer :type_flag
      t.integer :use_flag

      t.timestamps
    end
  end
end
