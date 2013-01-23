class Stock < ActiveRecord::Base
  has_many :users, :through => :user_stocks, :validate => false
  has_many :user_stocks
  attr_accessible :companyname, :companysymbol, :delta, :value

# stock_regex = /\A[A-Z]{1,4}\Z/
  SREGEX = /^[A-Z]{1,4}$/

  validates :companyname,	:presence => true
  validates :companysymbol,	:presence => true,
				:uniqueness => true,
  				:format => { :with => SREGEX },
 				:length => { :maximum => 4 }
  validates :value,		:numericality => { :greater_than_or_equal_to => 0.0 }
  validates :delta,		:numericality => true
#				:numericality => { :greater_than_or_equal_to => -1.0 * :value.to_f }

  validate  :delta_within_range
# validate  :valid_request?  # do separately, has side effects

  def self.randomize(stocks)
    puts "randomize stocks class: " + stocks.class.to_s + " " + stocks.count.to_s
    stocks.each do |s|
      oldval = s["value"].to_f
      del = Random.new().rand(-5.0...5.0).round(2)
      if oldval+del < 0.0; del = -del; end
      newval = (oldval + del).round(2)  # add/sub not perfect, must round
      s["value"] = newval
      s["delta"] = del
    end
    stocks
  end

  def self.in_db?(symba)  # class method
#   ab = Stock.where("companysymbol = ?", symba)
    ab = self.where("companysymbol = ?", symba)
    return ab.any?
  end

  def is_in_db?    # instance method
    puts "is_in_db companysymbol: " + self.companysymbol
    ab = Stock.where("companysymbol = ?", self.companysymbol)
    return ab.any?
  end
  
  def delta_within_range
    if (value.to_f).is_a?(Float) and (delta.to_f).is_a?(Float)
      if -1.0 * delta.to_f > value.to_f
	errors.add("Invalid","delta greater than value")
      end
    end
  end

# StockService.request_stocks() response:
#   "GOOG","Google Inc.","Sep 12 - <b>690.88</b>","-1.31 - -0.19%"
#   "ZYX","ZYX","N/A - <b>0.00</b>","N/A - N/A"
#   "CB","Chubb Corporation","Sep 12 - <b>75.80</b>","+0.58 - +0.77%"
#   "TSLA","Tesla Motors, Inc","Sep 12 - <b>28.28</b>","+0.48 - +1.73%"

# StockService.parse_response(res)
#   updated stock:
#   {"companysymbol"=>"GOOG", "value"=>"690.88", "delta"=>"-1.31"}
#   {"companysymbol"=>"ZYX", "value"=>"0.00", "delta"=>"-"}

#<Net::HTTPOK 200 OK readbody=true>
# stocks_hash: {0=>{"companysymbol"=>"DOCTYPE", "value"=>"\n", "delta"=>"."}}

  def valid_request?
#   return true  # avoid internet fail
# only want to run this on create(), not update()
# validations run on both, use separate call
#   if # companysymbol.valid?
puts "valid_request self: " + self.inspect
    unless self.companysymbol.match(SREGEX)
      errors.add("Invalid","stock symbol syntax")
      return false
    end
puts "company symbol passes regex"
#   only send http request if matches regex
    res = StockService.request_stocks(self.companysymbol)
    unless res.is_a?(Net::HTTPSuccess)
      errors.add("Invalid","stock symbol - http request failed")
      return false
    end
puts "response HTTPSuccess"
    stocks_hash = StockService.parse_response(res)  # only parses response
    
    # update params hash w/ new values
    stocks_hash.each do |index, sash|
# set new value, delta in self params
      self["value"] = sash["value"]
      self["delta"] = sash["delta"]
      puts "sash value=" + sash["value"] + " delta=" + sash["delta"]
# check if value, delta are reasonable
# full real number check done w/ numericality validation
      if sash["value"] == "0.00" ||
	sash["value"].to_f < 0 ||
	sash["delta"] == "-"
        errors.add("Invalid","stock symbol")
        return false
      end
    end

    true
  end
end