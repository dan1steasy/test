class SpellingErrorLicencesLicenseTypeId < ActiveRecord::Migration
  def self.up
    rename_column :licences, :license_type_id, :licence_type_id
  end

  def self.down
    rename_column :licences, :licence_type_id, :license_type_id
  end
end
