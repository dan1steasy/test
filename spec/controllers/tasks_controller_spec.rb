require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TasksController do

  def mock_task(stubs={})
    @mock_task ||= mock_model(Task, stubs)
  end


  before(:each) do
    session[:user] = 1
    session[:user_name] = 'admin'
    session[:list_limit] = 50
  end

  describe "GET index" do
    it "should find all tasks as @tasks" do
      Task.stub(:paginate).and_return([mock_task])
      get 'index'
      assigns[:tasks].should == [mock_task]
    end
  end

  describe "GET show" do
    it "should assign the requested task as @task" do
      Task.stub(:find).with('1').and_return(mock_task)
      get :show, :id => '1'
      assigns[:task].should == mock_task
    end
  end

  describe "GET 'new'" do
    before(:each) do
      Task.stub(:new).and_return(mock_task)
      get 'new'
    end

    it "should be successful" do
      response.should be_success
    end

    it "should assign a new task as @task" do
      assigns[:task].should equal(mock_task)
    end

  end

  describe "POST create" do
    describe "with valid params" do
      before(:each) do
        Task.stub(:new).with({'description' => 'task description'}).and_return(mock_task(:save => true))
        post :create, :task => {:description => 'task description'}
      end

      it "should assign a newly created task as @task" do
        assigns[:task].should equal(mock_task)
      end

      it "should set a flash[:notice]" do
        flash[:notice].should == "Task successfully created."
      end

      it "should redirect to show the list of tasks" do
        response.should redirect_to(tasks_path)
      end
    end

    describe "with invalid params (blank description)" do
      before(:each) do
        description = ''
        Task.stub(:new).with({'description' => description}).and_return(mock_task(:save => false))
        post :create, :task => {:description => description}
      end

      it "should assign a newly created but unsaved @task" do
        assigns[:task].should equal(mock_task)
      end

      it "should re-render the 'new' template" do
        response.should render_template('new')
      end
    end
  end
end
