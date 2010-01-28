require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

class Task; end

describe "/tasks/index.html.erb" do
  before(:each) do
    assigns[:tasks] = [
      stub_model(Task, :is_complete => false,
        :description => "task number one",
        :created_by => 1, :completed_by => nil,
        :created_at => 2.days.ago
      ),
      stub_model(Task, :is_complete => true,
        :description => "task number two",
        :created_by => 1, :completed_by => 1,
        :created_at => 1.days.ago
      )
    ]
    assigns[:tasks].stub!(:total_pages).and_return(1)
  end

  it "should render a list of tasks" do
    render 'tasks/index'
    response.should have_tag("tr>td", "task number one")
    response.should have_tag("tr>td", "task number two")
  end
end
