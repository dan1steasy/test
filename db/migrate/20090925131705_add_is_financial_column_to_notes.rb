class AddIsFinancialColumnToNotes < ActiveRecord::Migration
  def self.up
    add_column :notes, :is_financial, :bool, :default => false
  end

  def self.down
    remove_column :notes, :is_financial
  end
end
