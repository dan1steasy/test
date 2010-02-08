# == Schema Information
# Schema version: 20100208131342
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
#  completed_at :datetime      
#

class Task < ActiveRecord::Base
  attr_accessible :description, :is_complete

  validates_presence_of :description

  def complete?
    is_complete
  end

  def complete_string(invert=false)
    if invert
      self.complete? ? 'not completed' : 'completed'
    else
      self.complete? ? 'completed' : 'not completed'
    end
  end

  def created_by_user
    User.find(self.created_by).name
  end

  def updated_by_user
    User.find(self.updated_by).name unless self.updated_by.blank?
  end
end
