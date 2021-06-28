class CreateContentFrames < ActiveRecord::Migration
  def change
    create_table :content_frames do |t|
      t.string :title
      t.integer :content_frame_order
      t.integer :master_frame
      t.text :description

      t.timestamps
    end
  end
end
