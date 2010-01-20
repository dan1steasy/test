class SearchController < ApplicationController
  def index
    @query = params[:query]
    @accounts  = Account.find(:conditions => ["CONCAT(host_name, '.', domain_name) LIKE ? OR domain_name LIKE ?",
                                             "%#{@query}%", "%#{@query}%"], :order => 'domain_name, host_name')
    @companies = Company.find(:conditions => ["name LIKE ? OR address1 LIKE ? OR address2 LIKE ? OR town LIKE ? OR county LIKE ? OR country LIKE ? OR postcode LIKE ?",
                                              "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%"], :order => 'name')
    @contacts  = Contact.find
    @logins
    @notes
  end
end
