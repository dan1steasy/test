class MainController < ApplicationController
  
  def index
    @latest_accounts = Account.find(:all, :order => 'created_at DESC', :limit => 12)
    @latest_companies = Company.find(:all, :order => 'created_at DESC', :limit => 12)
    @incomplete_tasks = Task.find(:all, :order => 'created_at ASC',
                                  :conditions => ['is_complete = ?', false])
    #@notes = Note.find_with_recent_activity
  end

end
