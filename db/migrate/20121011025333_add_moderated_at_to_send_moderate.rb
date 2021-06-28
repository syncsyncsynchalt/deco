class AddModeratedAtToSendModerate < ActiveRecord::Migration
  def change
    add_column(:send_moderates, :moderated_at, :timestamp)
  end
end
