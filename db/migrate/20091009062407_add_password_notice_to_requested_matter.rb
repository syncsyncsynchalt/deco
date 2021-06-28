class AddPasswordNoticeToRequestedMatter < ActiveRecord::Migration
  def self.up
    add_column(:requested_matters, :password_notice, :integer)
  end

  def self.down
    remove_column(:requested_matters, :password_notice)
  end
end
