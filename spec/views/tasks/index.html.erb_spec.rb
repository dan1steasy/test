require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

class Task; end

describe "/tasks/index.html.erb" do
  before(:each) do
    assigns[:tasks] = [
      stub_model(Task, :id => 1,:is_complete => false,
        :description => "task number one",
        :created_by => 1, :completed_by => nil,
        :created_at => 2.days.ago
      ),
      stub_model(Task, :id => 2, :is_complete => true,
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
  
  it "should show an unchecked checkbox for an incomplete task" do
    render 'tasks/index'
    response.should have_selector("input", :type => "checkbox",
                                  :id => "task_1_complete",
                                  :value => "false")
  end

  it "should show a checked checkbox for a complete task" do
    render 'tasks/index'
    response.should have_selector("input", :type => "checkbox",
                                  :id => "task_2_complete",
                                  :checked => "checked", :value => "true")
  end
end
