class AddingCompanyContactDomainIdColumns < ActiveRecord::Migration
  def self.up
    add_column :notes, :company_id, :integer
    add_column :notes, :contact_id, :integer
    add_column :notes, :domain_id,  :integer
  end

  def self.down
    remove_column :notes, :domain_id
    remove_column :notes, :contact_id
    remove_column :notes, :company_id
  end
end
