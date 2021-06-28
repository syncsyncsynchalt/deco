class CreateReceivers < ActiveRecord::Migration
  def change
    create_table :receivers do |t|
      t.integer :send_matter_id
      t.string :name
      t.string :mail_address
      t.string :url

      t.timestamps
    end
  end
end
