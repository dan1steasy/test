class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.column :company_id, :integer, :null => false
      t.column :title, :string, :null => false, :default => 'Mr.'
      t.column :forename, :string
      t.column :middle_names, :string
      t.column :surname, :string
      t.column :phone1, :string
      t.column :phone2, :string
      t.column :fax, :string
      t.column :email, :string, :null => false
      t.column :position, :string
      t.column :is_subscribed, :bool, :null => false, :default => true
      t.column :is_billing_contact, :bool, :null => false
      t.column :is_general_contact, :bool, :null => false
      t.column :is_technical_contact, :bool, :null => false
      t.column :created_at, :date, :null => false
    end
  end

  def self.down
    drop_table :contacts
  end
end
