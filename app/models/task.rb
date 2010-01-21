# == Schema Information
# Schema version: 20100120120153
#
# Table name: tasks
#
#  id           :integer(4)    not null, primary key
#  description  :text          
#  is_complete  :boolean(1)    
#  created_by   :integer(4)    
#  updated_by   :integer(4)    
#  completed_by :integer(4)    
#  created_at   :datetime      
#  updated_at   :datetime      
#

class Task < ActiveRecord::Base
  attr_accessible :description, :is_complete

  #validates_presence_of :description

  def complete?
    is_complete
  end
end
