# == Schema Information
# Schema version: 20100208131342
#
# Table name: login_details
#
#  id                 :integer(4)    not null, primary key
#  description        :string(255)   
#  encrypted_username :binary        
#  encrypted_password :binary        
#  type               :string(255)   
#  account_id         :integer(4)    
#  company_id         :integer(4)    
#  contact_id         :integer(4)    
#  registrar_id       :integer(4)    
#  created_at         :date          
#  updated_at         :date          
#  created_by         :integer(4)    
#  updated_by         :integer(4)    
#  url                :text          
#

class LoginDetail < ActiveRecord::Base

  EXAMPLE_LOGIN_DESCRIPTIONS = ["Site admin", "Miva admin", "MySQL", "Server admin",
                                "Root user", "osCommerce admin"]
  
  attr_accessor :decrypted_username, :decrypted_password, :example_description

  def initialize(key, attributes = nil)
    super(attributes)
    @key = key
  end

  # A method to manually encrypt a username.
  def encrypt_username(key = @key)
    # TODO: add different sql statements for different DBs.
    sql = "UPDATE login_details
           SET encrypted_username =
           AES_ENCRYPT(#{quote_value(self.decrypted_username)}, #{quote_value(key)})
           WHERE id = #{self.id}"
    # Run this update manually.
    self.connection.execute sql
  end

  # A method to manually encrypt a password
  def encrypt_password(key = @key)
    # TODO: add different sql statements for different DBs.
    sql = "UPDATE login_details
           SET encrypted_password = 
           AES_ENCRYPT(#{quote_value(self.decrypted_password)}, #{quote_value(key)})
           WHERE id = #{self.id}"
    # Run this update manually.
    self.connection.execute sql
  end

  # A method to decrypt the username
  def decrypt_username(key = @key)
    sql = ["SELECT AES_DECRYPT(encrypted_username, ?) AS decrypted_username FROM login_details WHERE id = ?",
           key, self.id]
    result = LoginDetail.find_by_sql(sql)
    self.decrypted_username = result[0][:decrypted_username]
  end

  # A method to decrypt the password
  def decrypt_password(key = @key)
    sql = ["SELECT AES_DECRYPT(encrypted_password, ?) AS decrypted_password FROM login_details WHERE id = ?",
           key, self.id]
    result = LoginDetail.find_by_sql(sql)
    self.decrypted_password = result[0][:decrypted_password]
  end

end

class AccountLogin < LoginDetail
  belongs_to :account, :class_name => 'Account', :foreign_key => :account_id
end

class CompanyLogin < LoginDetail
  belongs_to :company, :class_name => 'Company', :foreign_key => :company_id
end

class ContactLogin < LoginDetail
  belongs_to :copntact, :class_name => 'Contact', :foreign_key => :contact_id
end

class RegistrarLogin < LoginDetail
  belongs_to :registrar, :class_name => 'Registrar', :foreign_key => :registrar_id
end
