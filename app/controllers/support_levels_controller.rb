class SupportLevelsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @support_levels = SupportLevel.paginate :per_page => session[:list_limit],
                                            :page => params[:page]
  end

  def show
    @support_level = SupportLevel.find(params[:id])
  end

  def new
    @support_level = SupportLevel.new
  end

  def create
    @support_level = SupportLevel.new(params[:support_level])
    if @support_level.save
      flash[:notice] = 'SupportLevel was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @support_level = SupportLevel.find(params[:id])
  end

  def update
    @support_level = SupportLevel.find(params[:id])
    if @support_level.update_attributes(params[:support_level])
      flash[:notice] = 'SupportLevel was successfully updated.'
      redirect_to :action => 'show', :id => @support_level
    else
      render :action => 'edit'
    end
  end

  def destroy
    SupportLevel.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
