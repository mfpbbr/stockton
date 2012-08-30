class StocksController < ApplicationController

  # GET /stocks
  # GET /stocks.json
  def index
    @stocks = Stock.all
    @bar = "baroo"
    @bar = StockService.foo
#   StockService.request_stocks

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @stocks }
    end
  end

  def getservice
    stocks = Stock.all  # if this is for User, should only get their stocks
    stock_ary = []
    stocks.each { |s| stock_ary << s.companysymbol }
# ultimately should not call StockService here, leave that for background task
# should only receive notification after background task runs
    res = StockService.request_stocks(stock_ary)
    sash = StockService.parse_response(res)
    sash.each_value do |params|   # similar to update
#     @stock = Stock.find(params[:id])
#     if @stock.update_attributes(params[:stock])
#     end
      stock = Stock.where("companysymbol = ?", params["companysymbol"]).first
      if stock.update_attributes(params)
puts "updated stock " + params.inspect
      else
puts "can't update stock " + params.inspect
      end
    end

    respond_to do |format|
#     format.html { redirect_to :action => "index", notice: 'Stock service redirects to index.' }
      format.html { redirect_to :action => "index" }
      format.json { render json: "index" }
    end
  end

  # GET /stocks/1
  # GET /stocks/1.json
  def show
    @stock = Stock.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @stock }
    end
  end

  # GET /stocks/new
  # GET /stocks/new.json
  def new
    @stock = Stock.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @stock }
    end
  end

  # GET /stocks/1/edit
  def edit
    @stock = Stock.find(params[:id])
  end

  # POST /stocks
  # POST /stocks.json
  def create
    @stock = Stock.new(params[:stock])

    respond_to do |format|
      if @stock.save
        format.html { redirect_to @stock, notice: 'Stock was successfully created.' }
        format.json { render json: @stock, status: :created, location: @stock }
      else
        format.html { render action: "new" }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /stocks/1
  # PUT /stocks/1.json
  def update
    @stock = Stock.find(params[:id])

    respond_to do |format|
      if @stock.update_attributes(params[:stock])
        format.html { redirect_to @stock, notice: 'Stock was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stocks/1
  # DELETE /stocks/1.json
  def destroy
    @stock = Stock.find(params[:id])
    @stock.destroy

    respond_to do |format|
      format.html { redirect_to stocks_url }
      format.json { head :no_content }
    end
  end
end