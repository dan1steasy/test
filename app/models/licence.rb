# == Schema Information
# Schema version: 82
#
# Table name: licences
#
#  id              :integer(11)   not null, primary key
#  licence_type_id :integer(11)   
#  expires_on      :date          
#  in_use          :boolean(1)    
#  value           :text          
#  account_id      :integer(11)   
#  created_on      :date          
#

class Licence < ActiveRecord::Base
  belongs_to :licence_type
  belongs_to :account

  validates_presence_of :value

  attr_accessor :no_expiry, :multiple
end
