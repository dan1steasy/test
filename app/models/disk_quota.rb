# == Schema Information
# Schema version: 20100208131342
#
# Table name: disk_quotas
#
#  id         :integer(4)    not null, primary key
#  account_id :integer(4)    
#  value      :float         
#

class DiskQuota < ActiveRecord::Base
  belongs_to :account

  UNIT = "GB"
end
