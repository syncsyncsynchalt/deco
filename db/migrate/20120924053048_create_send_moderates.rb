class CreateSendModerates < ActiveRecord::Migration
  def change
    create_table :send_moderates do |t|
      t.integer :send_matter_id
      t.integer :moderate_id
      t.string :name
      t.integer :type_flag
      t.integer :result

      t.timestamps
    end
  end
end
