class RenameOrderInContentFrame < ActiveRecord::Migration
  def self.up
    rename_column(:content_frames, :order, :content_frame_order)
  end

  def self.down
    rename_column(:content_frames, :content_frame_order, :order)
  end
end
