class CreateContentItems < ActiveRecord::Migration
  def self.up
    create_table :content_items do |t|
      t.integer :category
      t.string :string1
      t.text :text1
      t.string :url
      t.integer :flg
      t.integer :order
      t.integer :master_frame

      t.timestamps
    end
  end

  def self.down
    drop_table :content_items
  end
end
