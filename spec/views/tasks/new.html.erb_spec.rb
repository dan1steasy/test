require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

class Task; end

describe "/tasks/new" do
  before(:each) do
    #session[:user] = 1
    #session[:user_name] = 'admin'
    #session[:list_limit] = 50
    assigns[:task] = mock_model(Task).as_new_record.as_null_object
    render 'tasks/new'
  end
  
  it "should have the title 'New Datacentre Task'" do
    response.should have_tag('title',
                             'AutoEasy - New Datacentre Task')
  end

  it "should render a form to create a task" do
    response.should have_selector('form', :method => 'post',
                                  :action => tasks_path) do |form|
      form.should have_selector('input', :type => 'submit')
    end
  end
end
