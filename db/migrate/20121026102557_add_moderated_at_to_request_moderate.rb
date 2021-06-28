class AddModeratedAtToRequestModerate < ActiveRecord::Migration
  def change
    add_column(:request_moderates, :moderated_at, :timestamp)
  end
end
