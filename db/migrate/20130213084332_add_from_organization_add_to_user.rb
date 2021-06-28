class AddFromOrganizationAddToUser < ActiveRecord::Migration
  def change
    add_column(:users, :from_organization_add, :string, :default => nil)
    add_column(:users, :to_organization_add, :boolean, :default => 0)
  end
end
