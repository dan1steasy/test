class TasksController < ApplicationController
  def index
    @tasks = Task.paginate(:order => "created_at",
                           :per_page => session[:list_limit], :page => params[:page])
  end

  def show
    @task = Task.find(params[:id])
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(params[:task])
    @task.created_by = session[:user]
    if @task.save
      flash[:notice] = "Task successfully created."
      redirect_to tasks_path
    else
      render :action => :new
    end
  end

  def edit
    @task = Task.find(params[:id])
  end

  def update
    @task = Task.find(params[:id])
    if @task.update_attributes(params[:task])
      @task.update_attribute(:updated_by, session[:user])
      flash[:notice] = 'Task was successfully updated.'
      redirect_to(@task)
    else
      flash[:error] = "Could not update task!"
      render :action => "edit"
    end
  end
 
  def destroy
    @task = Task.find(params[:id])
    @task.destroy
    redirect_to tasks_url
  end

end
