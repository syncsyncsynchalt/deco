class AddFileUpDateToRequestedMatter < ActiveRecord::Migration
  def self.up
    add_column(:requested_matters, :file_up_date, :datetime)
  end

  def self.down
    remove_column(:requested_matters, :file_up_date)
  end
end
