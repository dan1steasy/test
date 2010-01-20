# == Schema Information
# Schema version: 20100120120153
#
# Table name: users
#
#  id            :integer(4)    not null, primary key
#  name          :string(255)   
#  real_name     :string(255)   
#  email         :string(255)   
#  password      :string(255)   
#  pin           :string(255)   
#  key           :binary        
#  list_limit    :integer(4)    default(15)
#  is_in_finance :boolean(1)    
#

class User < ActiveRecord::Base
  require 'digest/md5'
  
  validates_length_of       :name, :within => 3..40
  validates_length_of       :password, :within => 5..40
  validates_presence_of     :name
  validates_presence_of     :email
  validates_presence_of     :password, :on => :create
  validates_presence_of     :pin, :on => :create
  validates_uniqueness_of   :name, :email
  validates_format_of       :email,
                            :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_confirmation_of :password, :pin, :decrypted_key

  attr_accessor :decrypted_key
  
  def before_create
    hash_password(self.password)
    hash_pin(self.pin)
  end

  def before_destroy
    raise 'Cannot destroy admin user' if self.name == 'admin'
  end

  def self.authenticate(name, password, pin)
    user = User.find(:first,
                     :conditions => ["name = ? AND password = ? AND pin = ?",
                                    name, Digest::MD5.hexdigest(password),
                                    Digest::MD5.hexdigest(pin)])
    if user.blank?
      raise "Username, password or PIN invalid"
    end    
    user
  end
  
  def encrypt_key(decrypted_key)
    query = "UPDATE users SET `key` = AES_ENCRYPT('#{decrypted_key}', '#{self.pin}') WHERE id = #{self.id}"
    # Run this update manually
    self.connection.execute query
  end

  def decrypt_key
    # set up the queries for different DB types
    mysql_query = "SELECT id, AES_DECRYPT(`key`, pin) AS `key` FROM users WHERE id = #{self.id}"
    postgresql_query = ""
    
    # see which adapter we are using
    case ActiveRecord::Base.configurations[RAILS_ENV]['adapter']
      when "mysql"
        query = mysql_query
      when "postgresql"
        query = postgresql_query
    end
    
    result = User.find_by_sql(query)
    result[0].key
  end

  private
  def hash_password(pass)
    self.password = Digest::MD5.hexdigest(pass)
  end

  def hash_pin(pin)
    self.pin = Digest::MD5.hexdigest(pin)
  end
   
end
