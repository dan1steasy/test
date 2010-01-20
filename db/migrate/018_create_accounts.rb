class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.column :company_id,             :integer
      t.column :host_name,              :string
      t.column :domain_name,            :string
      t.column :domain_registration_id, :integer
      t.column :hardware_id,            :integer
      t.column :secure_link,            :string
      t.column :created_on,             :date
      t.column :support_level_id,       :integer
    end
  end

  def self.down
    drop_table :accounts
  end
end
