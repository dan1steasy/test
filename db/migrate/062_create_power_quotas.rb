class CreatePowerQuotas < ActiveRecord::Migration
  def self.up
    create_table :power_quotas do |t|
      t.column :company_id, :integer
      t.column :value, :float
    end
  end

  def self.down
    drop_table :power_quotas
  end
end
