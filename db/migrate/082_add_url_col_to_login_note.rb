class AddUrlColToLoginNote < ActiveRecord::Migration
  def self.up
    add_column :login_details, :url, :text
  end

  def self.down
    remove_column :login_details, :url
  end
end
