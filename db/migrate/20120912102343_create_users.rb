class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :login
      t.string :name
      t.string :email
      t.string :crypted_password, :limit => 40
      t.string :salt, :limit => 40
      t.integer :category
      t.text :note
      t.string :remember_token
      t.datetime :remember_token_expires_at

      t.timestamps
    end
  end
end
