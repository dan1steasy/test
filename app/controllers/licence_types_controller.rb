class LicenceTypesController < ApplicationController

  def index
    list
    render :action => 'list'
  end

  def list
    @total_licence_types = LicenceType.count
    @licence_types = LicenceType.paginate(:per_page => session[:list_limit],
                                          :order => 'name', :page => params[:page])
  end

  def show
    if request.post?
      id = params[:licence_type][:id]
    else
      id = params[:id]
    end
    redirect_to :controller => 'licences', :action => 'list', :id => id
  end

  def new
    @licence_type = LicenceType.new
  end

  def create
    @licence_type = LicenceType.new(params[:licence_type])
    if @licence_type.save
      flash[:notice] = 'Licence type successfully created.'
      redirect_to :controller => 'licences'
    else
      render :action => 'new'
    end
  end

  def edit
    @licence_type = LicenceType.find params[:id]
  end

  def update
    @licence_type = LicenceType.find params[:id]
    if @licence_type.update_attributes(params[:licence_type])
      flash[:notice] = 'Licence type successfully updated.'
      redirect_to :controller => 'licences'
    else
      render :action => 'edit'
    end
  end

  def destroy
    LicenceType.find(params[:id]).destroy
    flash[:notice] = 'Licence type deleted.'
    redirect_to :controller => 'licences'
  end
end
