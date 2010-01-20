class CreateBandwidthQuotas < ActiveRecord::Migration
  def self.up
    create_table :bandwidth_quotas do |t|
      t.column :account_id, :integer
      t.column :value, :float
    end
  end

  def self.down
    drop_table :bandwidth_quotas
  end
end
