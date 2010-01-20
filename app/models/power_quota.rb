# == Schema Information
# Schema version: 20090925131705
#
# Table name: power_quotas
#
#  id         :integer(4)    not null, primary key
#  company_id :integer(4)    
#  value      :float         
#

class PowerQuota < ActiveRecord::Base
  belongs_to :company

  UNIT = "Amps"
end
