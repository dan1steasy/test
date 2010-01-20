# == Schema Information
# Schema version: 20100120120153
#
# Table name: order_items
#
#  id               :integer(4)    not null, primary key
#  order_id         :integer(4)    
#  product_id       :integer(4)    
#  quantity         :float         
#  percent_discount :float         
#  fixed_discount   :integer(10)   
#  description      :text          
#  account_id       :integer(4)    
#

class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product
  belongs_to :account
end
