class CpController < ApplicationController

  def index
    @user_total    = User.count
    @company_total = Company.count
    @contact_total = Contact.count
    @account_total = Account.count
    @licence_total = Licence.count
    @ip_address_total = IpAddress.count
  end
end
