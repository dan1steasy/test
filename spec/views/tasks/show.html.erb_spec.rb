require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tasks/show.html.erb" do
  include TasksHelper
  before(:each) do
    assigns[:task] = @task = stub_model(Task,
      :description => "Description of task one",
      :is_complete => false,
      :created_by => 1,
      :updated_by => 1
    )
  end

  it "should render the attributes in a <p>" do
    pending
    render
    response.should have_text(/value\ for\ description/)
    response.should have_text(/false/)
    response.should have_text(/1/)
    response.should have_text(/1/)
  end
end
