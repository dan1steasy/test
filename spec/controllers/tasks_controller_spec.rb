require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TasksController do
  integrate_views

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

    it "should have the title 'New Datacentre Task'" do
      response.should have_tag('title',
                               'AutoEasy - New Datacentre Task')
    end

    it "should have a description label" do
      response.should have_tag('label', :for => 'task_description')
    end

    it "should have a description text area" do
      response.should have_tag('textarea', :id => 'task_description')
    end

    it "should have an 'Add task' submit button" do
      response.should have_tag('input', :type => 'submit',
                               :value => 'Add task')
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "should assign a newly created @task"
      it "should redirect to show the new @task"
    end

    describe "with invalid params" do
      it "should assign a newly created but unsaved @task"
      it "should re-render the 'new' template"
    end
  end
end
