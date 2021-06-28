class AddDescriptionToContentFrames < ActiveRecord::Migration
  def self.up
    add_column(:content_frames, :description, :text)
  end

  def self.down
    remove_column(:content_frames, :description)
  end
end
