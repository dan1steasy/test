# == Schema Information
# Schema version: 20090925131705
#
# Table name: account_types
#
#  id                :integer(4)    not null, primary key
#  name              :string(255)   
#  description       :string(255)   
#  product_id        :integer(4)    
#  requires_hardware :boolean(1)    
#  requires_hosting  :boolean(1)    
#

class AccountType < ActiveRecord::Base
  has_many :accounts

  validates_presence_of :name
end
