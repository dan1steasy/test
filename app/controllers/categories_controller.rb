class CategoriesController < ApplicationController

  #model :product

  auto_complete_for :category, :name

  in_place_edit_for :category, :name

  def index
    @total_categories = Category.count
    @categories = Category.find :all, :order => 'name'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    if params[:id]
      @search_phrase = params[:id]
      conditions = ["name LIKE ?", "#{@search_phrase}%" ]
      @total_categories = Category.count :conditions => conditions
      @categories = Category.paginate :order => 'name', :conditions => conditions,
                                      :per_page => session[:list_limit], :page => params[:page]
    else
      @total_categories = Category.count
      @categories = Category.paginate :order => 'name', :per_page => session[:list_limit],
                                      :page => [:page]
    end
  end

  def product_list
    begin
      @products = Category.find(params[:category][:id]).products
    rescue
      @products = {}
    end
    render :layout => false
  end

  def show
    if request.post?
      redirect_to :action => 'show', :id => params[:category][:id]
    else
      @category = Category.find params[:id]
    end
  end

  def search
    @search_phrase = params[:category][:name]
    @category_pages, @categories = paginate :categories, :order => :name,
                                            :per_page => session[:list_limit],
                                            :conditions => ["name LIKE ?", "%#{@search_phrase}%"]
    # If there is only one search result, just show the category
    if @categories.length == 1
      flash[:notice] = "<strong>#{@search_phrase}</strong> matched only one category - viewing category now."
      redirect_to :action => 'show', :id => @categories[0].id
    end
  end

  def new
    @category = Category.new
  end

  def new_product
    @product = Product.new
    # Assign the category_id to this product
    @product.category = Category.find params[:id]
  end

  def create
    @category = Category.new(params[:category])
    if @category.save
      flash[:notice] = 'Category was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])
    if @category.update_attributes(params[:category])
      flash[:notice] = 'Category was successfully updated.'
      redirect_to :action => 'show', :id => @category
    else
      render :action => 'edit'
    end
  end

  def destroy
    Category.find(params[:id]).destroy
    flash[:notice] = "Category deleted"
    redirect_to :action => 'list'
  end
end
