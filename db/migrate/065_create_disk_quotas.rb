class CreateDiskQuotas < ActiveRecord::Migration
  def self.up
    create_table :disk_quotas do |t|
      t.column :account_id, :integer
      t.column :value, :float
    end
  end

  def self.down
    drop_table :disk_quotas
  end
end
