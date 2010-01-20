class ChangeNoteDomainIdToAccountId < ActiveRecord::Migration
  def self.up
    rename_column :notes, :domain_id, :account_id
  end

  def self.down
    rename_column :notes, :account_id, :domain_id
  end
end
