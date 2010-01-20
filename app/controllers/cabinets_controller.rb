class CabinetsController < ApplicationController

  verify :method => :post, :only => [:destroy, :update]

  def check_available_cabinet_bays
    @cabinet = Cabinet.find params[:id]
    @free_cabinet_bay_list = @cabinet.available_bay_list(params[:u_size].to_i, params[:hardware_id])
    unless params[:starting_cabinet_bay].blank? || params[:starting_cabinet_bay].to_i == 0
      @hardware = Hardware.new 
      @hardware.starting_cabinet_bay = params[:starting_cabinet_bay]
    end
    render :update do |page|
      page << '<script type="text/javascript">'
      page.replace 'free_cabinet_bays',  '<div id="free_cabinet_bays">' + select(:hardware, :starting_cabinet_bay, @free_cabinet_bay_list) + '</div>'
      page.visual_effect :highlight, 'free_cabinet_bays'
      page << '</script>'
    end
  end

  def edit
    @cabinet = Cabinet.find params[:id]
    @datacentres = Datacentre.find :all, :order => 'name'
  end

  def update
    @cabinet = Cabinet.find params[:id]
    if @cabinet.update_attributes(params[:cabinet])
      @cabinet.reload
      flash[:notice] = "Cabinet details updated."
      redirect_to :controller => :dc, :action => :show, :id => @cabinet.datacentre,
                  :anchor => "cabinet_#{@cabinet.id}"
    else
      @datacentres = Datacentre.find :all, :order => 'name'
      flash[:error] = "Could not update cabinet details!"
      render :action => :edit
    end
  end

  def destroy
    @cabinet = Cabinet.find params[:id]
    @cabinet.destroy
    flash[:notice] = "Cabinet removed."
    redirect_to :controller => :dc, :action => :show, :id => @cabinet.datacentre.id
  end

end
