require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

class Task; end

describe "/tasks/show.html.erb" do
  before(:each) do
    assigns[:task] = stub_model(Task,
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
end
