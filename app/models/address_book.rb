class AddressBook < ActiveRecord::Base
  belongs_to :user
  attr_accessible :organization, :email, :from_email, :name, :notes, :user_id

  paginates_per 8
end
