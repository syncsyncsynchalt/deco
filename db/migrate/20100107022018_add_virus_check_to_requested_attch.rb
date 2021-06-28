class AddVirusCheckToRequestedAttch < ActiveRecord::Migration
  def self.up
    add_column(:requested_attachments, :virus_check, :string)
  end

  def self.down
    remove_column(:requested_attachments, :virus_check)
  end
end
