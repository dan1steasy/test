class AddWhoisNameColumnToRegistrars < ActiveRecord::Migration
  def self.up
    add_column :registrars, :whois_name, :string
  end

  def self.down
    remove_column :registrars, :whois_name
  end
end
