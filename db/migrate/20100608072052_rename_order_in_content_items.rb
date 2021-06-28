class RenameOrderInContentItems < ActiveRecord::Migration
  def self.up
    rename_column(:content_items, :order, :content_item_order)
  end

  def self.down
    rename_column(:content_items, :content_item_order, :order)
  end
end
