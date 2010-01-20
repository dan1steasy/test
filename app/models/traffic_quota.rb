# == Schema Information
# Schema version: 82
#
# Table name: traffic_quotas
#
#  id         :integer(11)   not null, primary key
#  company_id :integer(11)   
#  value      :float         
#

class TrafficQuota < ActiveRecord::Base
  belongs_to :company

  UNIT = "Mb/s"
end
