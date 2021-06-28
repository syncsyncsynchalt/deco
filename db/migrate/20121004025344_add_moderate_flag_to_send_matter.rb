class AddModerateFlagToSendMatter < ActiveRecord::Migration
  def change
    add_column(:send_matters, :moderate_flag, :integer)
    add_column(:send_matters, :moderate_result, :integer)
    add_column(:send_matters, :sent_at, :timestamp)
  end
end
