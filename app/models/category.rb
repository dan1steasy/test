# == Schema Information
# Schema version: 20100120120153
#
# Table name: categories
#
#  id   :integer(4)    not null, primary key
#  name :string(255)   
#

class Category < ActiveRecord::Base
  has_many :products, :dependent => :destroy

  validates_presence_of   :name
  validates_uniqueness_of :name
end
