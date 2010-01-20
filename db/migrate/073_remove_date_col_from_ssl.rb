class RemoveDateColFromSsl < ActiveRecord::Migration
  def self.up
    remove_column :ssls, :expires_on
  end

  def self.down
    add_column :ssls, :expires_on, :date
  end
end
