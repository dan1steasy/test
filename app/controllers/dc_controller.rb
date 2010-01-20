class DcController < ApplicationController

  require_dependency 'datacentre'

  in_place_edit_for :datacentre, :name
  in_place_edit_for :datacentre, :description

  def index
    @total_datacentres = Datacentre.count
    @datacentres = Datacentre.find :all, :order => 'name'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    if params[:id]
      @search_phrase = params[:id]
      @datacentres = Datacentre.paginate(:per_page => session[:list_limit], :page => params[:page],
                                         :order => :name, :conditions => ["name LIKE ?", "#{@search_phrase}%"])
    else
      @datacentres = Datacentre.paginate(:per_page => session[:list_limit], :order => :name,
                                         :page => params[:page])
    end
  end

  def show
    if request.post?
      logger.debug("DEBUG >> Received a POST request: #{params[:datacentre][:id]}")
      redirect_to :action => 'show', :id => params[:datacentre][:id] and return
    else
      create_objects(params[:id])
    end
    # We will show an 'add cabinet' form if the cabinet limit hasn't been reached
    logger.debug("DEBUG >> Current cabinet number: #{@datacentre.cabinets.size}")
    logger.debug("DEBUG >> Cabinet limit: #{@datacentre.cabinet_space}")
    if @datacentre.cabinets.size < @datacentre.cabinet_space
      @cabinet = Cabinet.new
      @cabinet.datacentre_id = @datacentre.id
    end
  end

  def show_cabinet
    @cabinet = Cabinet.find(params[:id].to_i, :include => 'hardware')
    @hardware = []
    @hardware[@cabinet.id] = []
    cab_ctr = 1
    @cabinet.u_space.times do
      hw = @cabinet.hardware.find_by_starting_cabinet_bay(cab_ctr)
      @hardware[@cabinet.id][cab_ctr] = hw
      cab_ctr += 1
      unless hw.blank?
        # Handle differing U sizes
        u_loop = hw.u_size - 1
        u_loop.times do
          @hardware[@cabinet.id][cab_ctr] = hw.id
          cab_ctr += 1
        end
      end
    end
    render :partial => 'cabinet_view', :locals => {:cabinet => @cabinet}
  end

  def show_all_cabinets
    if request.xhr?
      create_objects
      render :partial => 'all_cabinets'
    elsif request.get?
      # We will load the top of the page, an AJAX request will do the
      # real work of getting all the cabinet contents (above).
      @hardware_types = HardwareType.find :all
      @datacentres = Datacentre.find(:all, :order => 'name', :include => 'cabinets')
    end
  end

  def new
    @datacentre = Datacentre.new
  end

  def create
    @datacentre = Datacentre.new(params[:datacentre])
    if @datacentre.save
      flash[:notice] = 'Datacentre was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def create_cabinet
    @cabinet = Cabinet.new(params[:cabinet])
    if @cabinet.save
      flash[:notice] = "Cabinet in #{@cabinet.datacentre.name} successfully created."
      redirect_to :action => 'show', :id => @cabinet.datacentre_id
    else
      flash[:error] = "Cabinet could not be created."
      create_objects(@cabinet.datacentre.id)
      render :action => 'show'
    end
  end

  def edit
    @datacentre = Datacentre.find(params[:id])
  end

  def update
    @datacentre = Datacentre.find(params[:id])
    if @datacentre.update_attributes(params[:datacentre])
      flash[:notice] = 'Datacentre was successfully updated.'
      redirect_to :action => 'show', :id => @datacentre
    else
      render :action => 'edit'
    end
  end

  def destroy
    begin
      Datacentre.find(params[:id]).destroy
    rescue
      flash[:error] = $!
    end
    redirect_to :action => 'list'
  end

  private
  def create_objects(datacentre_id=nil)
    @hardware = []
    if datacentre_id.blank?
      # We need to load up every cabinet from every DC
      @cabinets = Cabinet.find :all, :order => 'datacentre_id, name'
      @cabinets.each do |cabinet|
        @hardware[cabinet.id] = []
        cab_ctr = 1
        cabinet.u_space.times do
          hw = cabinet.hardware.find_by_starting_cabinet_bay(cab_ctr)
          @hardware[cabinet.id][cab_ctr] = hw
          cab_ctr += 1
          unless hw.blank?
            # Handle differing U sizes
            u_loop = hw.u_size - 1
            u_loop.times do
              @hardware[cabinet.id][cab_ctr] = hw.id
              cab_ctr += 1
            end
          end
        end
      end
    else
      @datacentre = Datacentre.find(datacentre_id)
      # If we have more than 5 cabinets, we don't want to load them all up at once
      if @datacentre.cabinets.size <= 5
        @use_ajax_cabinets = false
        @datacentre.cabinets.each do |cabinet|
          @hardware[cabinet.id] = []
          cab_ctr = 1
          cabinet.u_space.times do
            hw = cabinet.hardware.find_by_starting_cabinet_bay(cab_ctr)
            @hardware[cabinet.id][cab_ctr] = hw
            cab_ctr += 1
            unless hw.blank?
              # Handle differing U sizes
              u_loop = hw.u_size - 1
              u_loop.times do
                @hardware[cabinet.id][cab_ctr] = hw.id
                cab_ctr += 1
              end
            end
          end
        end
      else
        @use_ajax_cabinets = true
      end
    end
    @hardware_types = HardwareType.find(:all, :order => 'name')
  end
end
