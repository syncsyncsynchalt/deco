class ModifyImageToMediumblobInContentItems < ActiveRecord::Migration
  def self.up
    execute("alter table content_items modify image mediumblob")
  end

  def self.down
    execute("alter table content_items modify image blob")
  end
end
