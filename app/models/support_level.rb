# == Schema Information
# Schema version: 20100208131342
#
# Table name: support_levels
#
#  id          :integer(4)    not null, primary key
#  code        :string(255)   
#  name        :string(255)   
#  description :text          
#

class SupportLevel < ActiveRecord::Base
end
