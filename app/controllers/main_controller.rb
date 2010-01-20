class MainController < ApplicationController
  
  def index
    @latest_accounts = Account.find(:all, :order => 'created_at DESC', :limit => 12)
    @latest_companies = Company.find(:all, :order => 'created_at DESC', :limit => 12)
  end

end
