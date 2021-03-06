require 'spec_helper'

describe "stocks routes" do
# needs both routes.rb and stock_controller.rb to pass

  it "GET /stocks to stocks#index" do
    { :get => "/stocks" }.should route_to(
      :controller => "stocks",
      :action => "index"
    )
  end

  it "GET root to stocks#home" do
    { :get => "/" }.should route_to(
      "stocks#home"  # shortcut notation, same as above
    )
  end

  it "GET /stocks/new to stocks#new" do
    { :get => "/stocks/new" }.should route_to(
      :controller => "stocks",
      :action => "new"
    )
  end

  it "POST /stocks to stocks#create" do
    { :post => "/stocks" }.should route_to(
      :controller => "stocks",
      :action => "create"
    )
  end

  it "DELETE /stocks/1 to stocks#destroy 1" do
    { :delete => "/stocks/1" }.should route_to(
      :controller => "stocks",
      :action => "destroy",
      :id => "1"
    )
  end

  it "POST /stockservice to stocks#sservice" do
    { :post => "/stockservice" }.should route_to(
      :controller => "stocks",
      :action => "sservice"
    )
  end

  it "GET /guestlog to stocks#guest_log" do
    { :get => "/guestlog" }.should route_to(
      :controller => "stocks",
      :action => "guestlog"
    )
  end
end
