class AddImageToContentItems < ActiveRecord::Migration
  def self.up
    add_column(:content_items, :image, :binary)
  end

  def self.down
    remove_column(:content_items, :image)
  end
end
