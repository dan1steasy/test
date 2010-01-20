class AddingIsInFinanceColumnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_in_finance, :bool, :default => false
  end

  def self.down
    remove_column :users, :is_in_finance
  end
end
