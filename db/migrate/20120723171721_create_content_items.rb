class CreateContentItems < ActiveRecord::Migration[4.2]
  def change
    create_table :content_items do |t|
      t.integer :category
      t.string :string1
      t.text :text1
      t.string :url
      t.integer :flg
      t.integer :content_item_order
      t.integer :master_frame
      t.binary :image, :limit => 15.megabyte

      t.timestamps
    end
  end
end
