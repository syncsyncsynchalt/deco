class CreateContentItems < ActiveRecord::Migration
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
#    rename_column(:content_items, :order, :content_item_order)
#    add_column(:content_items, :image, :binary)
#    execute("alter table content_items modify image mediumblob")

      t.timestamps
    end
  end
end
