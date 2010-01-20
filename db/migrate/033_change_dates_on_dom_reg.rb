class ChangeDatesOnDomReg < ActiveRecord::Migration
  def self.up
    add_column :domain_registrations, :registration_date, :date
    add_column :domain_registrations, :last_updated, :date
    rename_column :domain_registrations, :last_expired_on, :renewal_date
  end

  def self.down
    rename_column :domain_registrations, :renewal_date, :last_expired_on
    delete_column :domain_registrations, :last_updated
    delete_column :domain_registrations, :registration_date
  end
end
