class CreateRequestModeraters < ActiveRecord::Migration
  def change
    create_table :request_moderaters do |t|
      t.integer :request_moderate_id
      t.integer :moderater_id
      t.integer :user_id
      t.integer :user_name
      t.integer :number
      t.text :content
      t.integer :send_flag
      t.integer :result
      t.string :url

      t.timestamps
    end
  end
end
