class HardwareTypesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @hardware_types = HardwareType.paginate :per_page => session[:list_limit],
                                            :page => params[:page]
  end

  def show
    @hardware_type = HardwareType.find(params[:id])
  end

  def new
    @hardware_type = HardwareType.new
  end

  def create
    @hardware_type = HardwareType.new(params[:hardware_type])
    if @hardware_type.save
      flash[:notice] = 'HardwareType was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @hardware_type = HardwareType.find(params[:id])
  end

  def update
    @hardware_type = HardwareType.find(params[:id])
    if @hardware_type.update_attributes(params[:hardware_type])
      flash[:notice] = 'HardwareType was successfully updated.'
      redirect_to :action => 'show', :id => @hardware_type
    else
      render :action => 'edit'
    end
  end

  def destroy
    HardwareType.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
