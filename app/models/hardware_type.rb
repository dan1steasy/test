# == Schema Information
# Schema version: 82
#
# Table name: hardware_types
#
#  id        :integer(11)   not null, primary key
#  name      :string(255)   
#  colour    :string(255)   
#  admin_url :string(255)   
#

class HardwareType < ActiveRecord::Base
  has_many :hardware

  validates_presence_of :name
  validates_format_of :colour, :with => /^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/
  validates_format_of :admin_url, :with => /^http(s)?:\/\//, :if => :admin_url_not_nil?

  def count_hardware_in_dc(dc)
    datacentre = Datacentre.find dc.id
    count = 0
    datacentre.cabinets.each do |cab|
      count += cab.hardware.count(:conditions => ["hardware_type_id = ?", self.id])
    end
    return count
  end

  def count_hardware
    cabinets = Cabinet.find :all
    count = 0
    cabinets.each do |cab|
      count += cab.hardware.count(:conditions => ["hardware_type_id = ?", self.id])
    end
    return count
  end

  def admin_url_link(fqdn)
    self.admin_url.gsub('$DOMAIN', fqdn)
  end

  def admin_url_not_nil?
    if self.admin_url.blank?
      false
    else
      true
    end
  end
  alias has_admin_url? admin_url_not_nil?
end
