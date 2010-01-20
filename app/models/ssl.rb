# == Schema Information
# Schema version: 82
#
# Table name: ssls
#
#  id          :integer(11)   not null, primary key
#  account_id  :integer(11)   not null
#  key         :text          
#  request     :text          
#  certificate :text          
#

class Ssl < ActiveRecord::Base
  belongs_to :account

  validates_format_of :key,
                      :with => /^-----BEGIN RSA PRIVATE KEY-----/
  validates_format_of :request,
                      :with => /^-----BEGIN CERTIFICATE REQUEST-----/
  validates_format_of :certificate,
                      :with => /^-----BEGIN CERTIFICATE-----/

  # Method to read the expiry date from the certificate
  def expires_on
    expiry_date = nil
    dates = %x{echo "#{self.certificate}" | openssl x509 -noout -dates}
    dates.each_line do |date_line|
      logger.debug("DEBUG >> Date line: #{date_line}")
      if date_line =~ /^notAfter=/
        expiry_date = date_line.gsub('notAfter=', '').to_time
      end
    end
    expiry_date
  end

  # Method to read the common name (domain) from the certificate
  def common_name
    subject = %x{echo "#{self.certificate}" | openssl x509 -noout -subject}
    subject.gsub(/^(.*)CN=/, '').strip
  end
  alias domain common_name

  # Method to read the certificate issuer
  def issuer
    issuer = %x{echo "#{self.certificate}" | openssl x509 -noout -issuer}
    issuer.gsub(/^(.*)O=/,'').gsub(/\/(.*)$/, '')
  end

end
