class CreateRequestMatters < ActiveRecord::Migration[4.2]
  def change
    create_table :request_matters do |t|
      t.string :name
      t.string :mail_address
      t.text :message
      t.string :url

      t.timestamps
    end
  end
end
