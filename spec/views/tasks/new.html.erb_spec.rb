require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

class Task; end
#session[:user] = 1
#session[:user_name] = 'admin'
#session[:list_limit] = 50

describe "/tasks/new" do
  before(:each) do
    assigns[:task] = mock_model(Task).as_new_record.as_null_object
    render 'tasks/new'
  end
  
  it "should render a form to create a task" do
    response.should have_selector('form', :method => 'post',
                                  :action => tasks_path) do |form|
      form.should have_selector('input', :type => 'submit')
    end
  end
  
  it "should render a label for the task description field" do
    response.should have_selector("form") do |form|
      form.should have_tag("label[for=task_description]", "Task description:")
    end
  end

  it "should render a text area for the task description" do
    response.should have_selector("form") do |form|
      form.should have_selector("textarea",
                                :name => "task[description]")
    end
  end

end
