# == Schema Information
# Schema version: 82
#
# Table name: licence_types
#
#  id          :integer(11)   not null, primary key
#  name        :string(255)   
#  description :text          
#

class LicenceType < ActiveRecord::Base
  has_many :licences, :dependent => :destroy

  validates_presence_of :name

  def available_licences
    Licence.find(:all, :conditions => ["licence_type_id = #{self.id} AND in_use = FALSE"]).length
  end

  def next_available_licence
    Licence.find(:first, :conditions => ["licence_type_id = #{self.id} AND in_use = FALSE"],
                 :order => 'created_on DESC')
  end
end
