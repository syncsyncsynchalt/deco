class AddModeratedAtToRequestModerate < ActiveRecord::Migration[4.2]
  def change
    add_column(:request_moderates, :moderated_at, :timestamp)
  end
end
