class CreateDomainRegistrations < ActiveRecord::Migration
  def self.up
    create_table :domain_registrations do |t|
      t.column :company_id,       :integer
      t.column :tld,              :string
      t.column :domain_name,      :string
      t.column :registrar_id,     :integer
      t.column :last_expired_on,  :date
      t.column :reg_period,       :integer
    end
  end

  def self.down
    drop_table :domain_registrations
  end
end
