class AddModerateFlagToRequestMatter < ActiveRecord::Migration[4.2]
  def change
    add_column(:request_matters, :moderate_flag, :integer)
    add_column(:request_matters, :moderate_result, :integer)
    add_column(:request_matters, :sent_at, :timestamp)
  end
end
