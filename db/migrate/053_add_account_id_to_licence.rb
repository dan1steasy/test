class AddAccountIdToLicence < ActiveRecord::Migration
  def self.up
    add_column :licences, :account_id, :integer
  end

  def self.down
    remove_column :licence, :account_id
  end
end
