class DeleteWhoisNameColumnFromRegistrars < ActiveRecord::Migration
  def self.up
    remove_column :registrars, :whois_name
  end

  def self.down
    add_column :registrars, :whois_name, :string
  end
end
