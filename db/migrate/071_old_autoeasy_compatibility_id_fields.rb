class OldAutoeasyCompatibilityIdFields < ActiveRecord::Migration
  def self.up
    add_column :companies, :old_id, :integer
    add_column :contacts, :old_id, :integer
  end

  def self.down
    remove_column :contacts, :old_id
    remove_column :companies, :old_id
  end
end
