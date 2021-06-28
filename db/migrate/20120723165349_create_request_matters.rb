class CreateRequestMatters < ActiveRecord::Migration
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
