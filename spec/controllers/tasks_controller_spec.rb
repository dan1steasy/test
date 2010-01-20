require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TasksController do
  #integrate_views

  def mock_task(stubs={})
    @mock_task ||= mock_model(Task, stubs)
  end


  before(:each) do
    session[:user] = 1
    session[:user_name] = 'admin'
    session[:list_limit] = 50
  end

  describe "GET 'new'" do
    before(:each) do
      get 'new'
    end

    it "should be successful" do
      response.should be_success
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "should assign a newly created @task" do
        post :create,
          Task.stub(:new).with({'description' => 'task description'}).and_return(mock_task(:save => true))
        assigns[:task].should equal(mock_task)
      end
      it "should redirect to show the new @task"
    end

    describe "with invalid params" do
      it "should assign a newly created but unsaved @task"
      it "should re-render the 'new' template"
    end
  end
end
