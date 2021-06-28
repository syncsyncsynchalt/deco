class CreateContentFrames < ActiveRecord::Migration
  def self.up
    create_table :content_frames do |t|
      t.string :title
      t.integer :order
      t.integer :master_frame

      t.timestamps
    end
  end

  def self.down
    drop_table :content_frames
  end
end
