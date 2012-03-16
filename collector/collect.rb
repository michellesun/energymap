#  This script collects and organizes various data per country. For now, the only source is the data world bank (http://data.worldbank.org/)
# The collector collects the following data for every country: 
# Economy related: GDP, GDP per capita, GDP growth
# Energy: energy production, energy use, energy imports, alternative and nuclear energy, GDP per unit of energy use, pump price for diesel fuel, road sector energy consumption percentage,  electric power consumption
# Environment: CO2 emmisions, CO2 emissions per capita
# Other: motor vehicles/1000 people, passenger cars/1000 people, urban population percentage, urban population
require 'open-uri'
require 'json'
require 'csv'

def db_request(req, options = {}, debug = false)
  options_str = ""
  options.each do |key, val|
    options_str << "&#{key}=#{val}"
  end
  request = "http://api.worldbank.org/#{req}?format=json&per_page=500#{options_str}"
  puts ">>>" + request if debug
  reply = URI.parse(request).read
  puts "<<<" + reply + "\n\n" if debug 
  JSON.parse(reply)[1]
end

def get_indicators
  JSON.parse(File.read('indicators.json'), :symbolize_names => true)
end

class CountryList
  include Enumerable
  @@indicators = get_indicators
  def initialize
    @countries = {}
  end

  def each
    @countries.each do |id, country|
      yield(country) if block_given?
    end
  end

  def populate_from_data_bank!
    data = db_request("countries")
    data.each do |country|
      @countries[country["iso2Code"]] = {:id => country["id"], :iso2_code => country["iso2Code"], :name => country["name"], :capital => country["capitalCity"], :region_id => country["region"]["id"]}
    end
  end

  def get_country_data(country)
    @@indicators.each do |indicator_name, indicator_code|
      debug = false
      begin
        response = db_request("countries/#{country[:id]}/indicators/#{indicator_code}", {:date => "2000:2012", :MRV => 1}, debug)
        country[indicator_name] = response[0]["value"] unless response.nil? or response[0].nil?
      rescue Exception => msg
        unless debug
          puts "[ERROR] #{msg}\nRetrying with debug flag on..." 
          debug = true
          retry
        end
        puts "[END]"
        raise Exception
      end
    end
  end

  def load_from_data_bank!
    @@indicators.each do |indicator_name, indicator_code|
      response = db_request("/countries/all/indicators/#{indicator_code}", {:date => "2000:2012", :MRV => 1})
      next if response.nil?
      response.each do |c|
        next unless @countries.has_key? c["country"]["id"]
        @countries[c["country"]["id"]][indicator_name] = c["value"]
      end
    end
  end
end

countries = CountryList.new
puts "Getting country info..."
countries.populate_from_data_bank!
puts "Done, #{countries.count} countries found."
puts "Getting data for each country..."
countries.load_from_data_bank!
puts "Done."
puts "Writing to countries.csv..."
CSV.open("countries.csv", "wb") do |csv|
  csv << countries.first.keys
  countries.each do |country|
    csv << country.values.map { |x| (x.nil?)?"ND":x}
  end
end
puts "All done."

