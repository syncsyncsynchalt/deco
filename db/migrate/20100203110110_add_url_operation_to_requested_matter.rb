class AddUrlOperationToRequestedMatter < ActiveRecord::Migration
  def self.up
    add_column(:requested_matters, :url_operation, :string)
  end

  def self.down
    remove_column(:requested_matters, :url_operation)
  end
end
