require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

class Task; end

describe "/tasks/show.html.erb" do
  before(:each) do
    assigns[:task] = stub_model(Task, :id => 1,
      :description => "Description of this task",
      :is_complete => false,
      :created_by => 1,
      :updated_by => 1
    )
    render 
  end

  it "should render the description in a <p>" do
    response.should have_tag("p", "Description of this task")
  end

  it "should render the is_complete attribute in a checkbox" do
    response.should have_tag("input", :type => "checkbox", 
                             :id => "task_is_complete")
  end

  it "should provide a link to edit the task" do
    pending
    #response.should have_tag("a[href~=/.*\/tasks\/1\/edit$/]", "Edit task")
    #response.should have_selector('a', :href => /.*\/tasks\/1\/edit$/,
    #                              :content => "Edit task")
  end

  it "should provide a link to delete the task" do
    pending
    response.should have_tag("a[href=/tasks/1$]", "Delete task", :method => "delete",
                             :confirm => "Are you sure you want to delete this task?")
  end

  it "should show who created the task"

  it "should show who updated the task"

end
