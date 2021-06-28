class AddExpressionFlagToContentFlame < ActiveRecord::Migration[4.2]
  def change
    add_column(:content_frames, :expression_flag, :integer)
  end
end
