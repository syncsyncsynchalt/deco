class CreateUserCategories < ActiveRecord::Migration
  def self.up
    create_table :user_categories do |t|
      t.integer :code
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :user_categories
  end
end
