class AddModeratedAtToSendModerate < ActiveRecord::Migration[4.2]
  def change
    add_column(:send_moderates, :moderated_at, :timestamp)
  end
end
