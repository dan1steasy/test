class TasksController < ApplicationController
  def index
    @tasks = Task.paginate(:order => "created_at",
                           :per_page => session[:list_limit], :page => params[:page])
  end

  def show
    if params[:id] == 'list' # catch our old-style 'list' URL
      redirect_to tasks_path
    else
      @task = Task.find(params[:id])
    end
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
    # We want to capture task completions
    old_is_complete = @task.is_complete
    if @task.update_attributes(params[:task])
      @task.update_attribute(:updated_by, session[:user])
      if(old_is_complete == false && @task.is_complete == true)
        # Task has just been completed
        @task.update_attribute(:completed_by, session[:user])
        @task.update_attribute(:completed_at, Time.now)
      elsif(old_is_complete == true && @task.is_complete == false)
        # Task has been marked as incomplete - clear out completed_by attribute
        @task.update_attribute(:completed_by, nil)
        @task.update_attribute(:completed_at, nil)
      end
      flash[:notice] = 'Task was successfully updated.'
      redirect_to(params[:redirect_to] || @task)
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
