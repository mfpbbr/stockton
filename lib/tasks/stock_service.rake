namespace :sservice do
  
  task :default => [:update]

  desc "update stocks"
  task :update => [:environment] do |t, args|
    puts "Stock count: #{Stock.count}"
    StockService.request
  end
  
  desc "randomize stocks"
  task :random => [:environment] do |t, args|
#   Rake::Task['stocks:yayy'].invoke
    puts "Stock count: #{Stock.count}"
    StockService.fake_request
  end

#  desc "yayy"
#  task :yayy do
#    yays = ENV['YAYS'].to_i || 2
#    puts "yayy!! " * yays
#  end
#
#   $ YAYS=3; export YAYS
  
  file "execrun" do
    sh "../../script/run_service.sh"
  end
end
