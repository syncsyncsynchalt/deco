class AddModerateFlagToSendMatter < ActiveRecord::Migration[4.2]
  def change
    add_column(:send_matters, :moderate_flag, :integer)
    add_column(:send_matters, :moderate_result, :integer)
    add_column(:send_matters, :sent_at, :timestamp)
  end
end
