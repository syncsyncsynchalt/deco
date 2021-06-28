class AddVirusCheckToAttachments < ActiveRecord::Migration
  def self.up
    add_column(:attachments, :virus_check, :string)
  end

  def self.down
    remove_column(:attachments, :virus_check)
  end
end
