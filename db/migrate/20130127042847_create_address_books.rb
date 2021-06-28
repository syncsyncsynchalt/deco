class CreateAddressBooks < ActiveRecord::Migration[4.2]
  def change
    create_table :address_books do |t|
      t.integer :user_id
      t.string :from_email
      t.string :name
      t.string :email
      t.string :organization
      t.string :notes

      t.timestamps
    end
  end
end
