class CreateTrafficQuotas < ActiveRecord::Migration
  def self.up
    create_table :traffic_quotas do |t|
      t.column :account_id, :integer
      t.column :value, :float
    end
  end

  def self.down
    drop_table :traffic_quotas
  end
end
