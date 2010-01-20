# == Schema Information
# Schema version: 82
#
# Table name: datacentres
#
#  id            :integer(11)   not null, primary key
#  name          :string(255)   
#  description   :text          
#  cabinet_space :integer(11)   
#

class Datacentre < ActiveRecord::Base
  has_many :cabinets, :order => :name

  validates_uniqueness_of   :name
  validates_presence_of     :name
  validates_numericality_of :cabinet_space

  def before_destroy
    # Check for hardware in cabinets
    raise 'Datacentre not empty - move hardware first' if hardware_count > 0
  end

  def hardware_count
    hw_count = 0
    cabinets.each do |cabinet|
      hw_count += cabinet.hardware.count
    end
    hw_count
  end

  def subscribed_contacts
  end
end
