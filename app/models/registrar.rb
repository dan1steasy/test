# == Schema Information
# Schema version: 82
#
# Table name: registrars
#
#  id                 :integer(11)   not null, primary key
#  name               :string(255)   
#  url                :string(255)   
#  encrypted_username :binary        
#  encrypted_password :binary        
#  has_api            :boolean(1)    
#  valid_tlds         :string(255)   
#

class Registrar < ActiveRecord::Base
  has_many :domain_registrations
  has_one  :registrar_login

  validates_presence_of   :name
  validates_uniqueness_of :name

  attr_accessor :decrypted_username, :decrypted_password

  # A method to manually encrypt a username.
  def encrypt_username(key)
    # TODO: add different sql statements for different DBs.
    sql = "UPDATE registrars
           SET encrypted_username =
           AES_ENCRYPT(#{quote(self.decrypted_username)}, #{quote(key)})
           WHERE id = #{self.id}"
    # Run this update manually.
    self.connection.execute sql
  end

  # A method to manually encrypt a password
  def encrypt_password(key)
    # TODO: add different sql statements for different DBs.
    sql = "UPDATE registrars
           SET encrypted_password = 
           AES_ENCRYPT(#{quote(self.decrypted_password)}, #{quote(key)})
           WHERE id = #{self.id}"
    # Run this update manually.
    self.connection.execute sql
  end

  # A method to decrypt the username
  def decrypt_username(key)
    sql = ["SELECT AES_DECRYPT(encrypted_username, ?) AS decrypted_username FROM registrars WHERE id = ?",
           key, self.id]
    result = Registrar.find_by_sql(sql)
    self.decrypted_username = result[0][:decrypted_username]
  end

  # A method to decrypt the password
  def decrypt_password(key)
    sql = ["SELECT AES_DECRYPT(encrypted_password, ?) AS decrypted_password FROM registrars WHERE id = ?",
           key, self.id]
    result = Registrar.find_by_sql(sql)
    self.decrypted_password = result[0][:decrypted_password]
  end

  # Method to synchronise the domain_registrations DB with
  # an API-based.
  def synchronise_domains
    if self.has_api
      require "#{self.name.downcase}/api_request"
      api = ApiRequest.new(self.decrypted_username, self.decrypted_password, self.url)
      # TODO: Do something magical...
    else
      false
    end
  end

  # Method to count the registered domains from an API
  def registered_domain_count
    if self.has_api
      require "#{self.name.downcase}/api_request"
      api_request = ApiRequest.new(self.decrypted_username,
                                   self.decrypted_password,
                                   self.url)
      result = api_request.get_domain_count
      result['RegisteredCount'].to_i
    else
      return nil
    end
  end

  # Method to count the expired domains from an API
  def expired_domain_count
    if self.has_api
      require "#{self.name.downcase}/api_request"
      api_request = ApiRequest.new(self.decrypted_username,
                                   self.decrypted_password,
                                   self.url)
      result = api_request.get_domain_count
      result['ExpiredDomainsCount'].to_i
    else
      return nil
    end
  end
end
