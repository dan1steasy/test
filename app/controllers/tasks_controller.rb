class TasksController < ApplicationController
  def index
    @tasks = Task.all
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(params[:task])
    if @task.save
      flash[:notice] = "Task successfully created."
      redirect_to tasks_path
    else
      render :action => :new
    end
  end

end
