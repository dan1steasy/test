class CompaniesContacts < ActiveRecord::Migration
  def self.up
    create_table :companies_contacts, :id => false do |t|
      t.column :company_id, :integer
      t.column :contact_id, :integer
    end

    remove_column :contacts, :company_id
  end

  def self.down
    add_column :contacts, :company_id, :integer

    drop_table :companies_contacts
  end
end
