class ProductsController < ApplicationController

  #model :category

  auto_complete_for :product, :name
  auto_complete_for :product, :code
  auto_complete_for :product, :description

  Product.content_columns.each do |column|
    in_place_edit_for :product, column.name
  end

  def index
    @total_products = Product.count
    @products = Product.find :all, :order => 'name' unless @total_products > 500
    @categories = Category.find :all, :order => 'name'
  end

  verify :method => :post, :only => [:destroy, :create, :update],
         :redirect_to => {:action => :list}

  def list
    if params[:id]
      @search_phrase = params[:id]
      @total_products = Product.count ['name LIKE ?', "#{@search_phrase}%"]
      @product_pages, @products = paginate :products, :order => 'name',
                                           :per_page => session[:list_limit],
                                           :conditions => ['name LIKE ?', "#{@search_phrase}%"]
    else
      @total_products = Product.count
      @product_pages, @products = paginate :products, :order => 'name',
                                           :per_page => session[:list_limit]
    end
  end

  def show
    @categories = Category.find :all, :order => 'name'
    if request.post?
      redirect_to :action => 'show', :id => params[:product][:id]
    else
      @product = Product.find params[:id]
    end
  end

  def search
    if params[:product] != nil
      if params[:product][:name]
        @search_phrase = params[:product][:name]
        cond_array = ["name LIKE ?", "%#{@search_phrase}%"]
      elsif params[:product][:code]
        @search_phrase = params[:product][:code]
        cond_array = ["code LIKE ?", "%#{@search_phrase}%"]
      elsif params[:product][:description]
        @search_phrase = params[:product][:description]
        cond_array = ["description LIKE ?", "%#{@search_phrase}%"]
      end
    end

    @product_pages, @products = paginate :products, :order => 'name',
                                         :per_page => session[:list_limit],
                                         :conditions => cond_array
    # If there was only one search result, just show that product.
    if @products.length == 1
      flash[:notice] = "<em>#{@search_phrase}</em> matched only one product - viewing product now."
      redirect_to :action => :show, :id => @products[0].id
    end
  end

  def new
    # We need all available categories to put in a drop-down.
    @categories = Category.find :all, :order => 'name'
    @product = Product.new
  end

  def create
    # We need all available categories to put in a drop-down.
    @categories = Category.find :all, :order => 'name'
    @product = Product.new params[:product]
    if @product.save
      flash[:notice] = 'Product was successfully created.'
      redirect_to :action => 'show', :id => @product
    else
      render :action => 'new'
    end
  end

  def edit
    @categories = Category.find :all, :order => 'name'
    @product = Product.find params[:id]
  end

  def update
    @product = Product.find params[:id]
    if @product.update_attributes params[:product]
      flash[:notice] = 'Product was successfully updated.'
      redirect_to :action => 'show', :id => @product
    else
      flash[:error] = 'Product was not updated.'
      render :action => 'edit'
    end
  end

  def destroy
    Product.find(params[:id]).destroy
    flash[:notice] = 'Product deleted'
    redirect_to :action => 'index'
  end

  # Handle in-place edit of category name separately
  def set_product_category_name
    @product = Product.find params[:id]
    # We will receive a category_id (as params[:value]), not a name
    @product.update_attribute(:category_id, params[:value])
    render :text => @product.category.name
  end

end
