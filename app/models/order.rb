# == Schema Information
# Schema version: 20090925131705
#
# Table name: orders
#
#  id          :integer(4)    not null, primary key
#  created_at  :datetime      
#  user_id     :integer(4)    
#  company_id  :integer(4)    
#  contact_id  :integer(4)    
#  is_complete :boolean(1)    
#

class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :company
  belongs_to :contact

  has_many :order_items
end
