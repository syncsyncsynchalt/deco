class CreateRequestModerates < ActiveRecord::Migration
  def change
    create_table :request_moderates do |t|
      t.integer :request_matter_id
      t.integer :moderater_id
      t.string :name
      t.integer :type_flag
      t.integer :result

      t.timestamps
    end
  end
end
