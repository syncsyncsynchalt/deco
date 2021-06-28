class AddColumnModerateIdToRequestModerates < ActiveRecord::Migration[5.1]
  def change
    add_column(:request_moderates, :moderate_id, :integer, :after => :request_matter_id)
  end
end
