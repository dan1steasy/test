class AddingListSizeFieldToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :list_limit, :integer, :default => 15
  end

  def self.down
    remove_column :users, :list_limit
  end
end
