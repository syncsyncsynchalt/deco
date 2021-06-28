class CreateRequestMatters < ActiveRecord::Migration
  def self.up
    create_table :request_matters do |t|
      t.string :name
      t.string :mail_address
      t.text :message
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :request_matters
  end
end
