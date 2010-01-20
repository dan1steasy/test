class CreateIpAddresses < ActiveRecord::Migration
  def self.up
    create_table :ip_addresses do |t|
      t.column :address, :string, :null => false, :limit => 15
      t.column :company_id, :integer
      t.column :hardware_id, :integer
    end
  end

  def self.down
    drop_table :ip_addresses
  end
end
