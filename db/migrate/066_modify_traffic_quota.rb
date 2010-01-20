class ModifyTrafficQuota < ActiveRecord::Migration
  def self.up
    rename_column :traffic_quotas, :account_id, :company_id
  end

  def self.down
    rename_column :traffic_quotas, :company_id, :account_id
  end
end
