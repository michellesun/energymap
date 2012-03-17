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

class Hash
  def export_to_json(file)
    File.open(file, 'w') do |file|
      file.write to_json
    end
  end

  def set_if_greater(name, value)
    return if value.nil?
    if has_key?(name)
      self[name] = value if value > self[name]
    else
      self[name] = value
    end
  end

  def set_if_smaller(name, value)
    return if value.nil?
    if has_key?(name)
      self[name] = value if value < self[name]
    else
      self[name] = value
    end
  end
end 

class CountryList
  include Enumerable
  attr_reader :attributes

  @@indicators = get_indicators
  def initialize
    @countries = {}
    @attributes = {}
    @@indicators.each do |name, code|
      @attributes[name] = {:code => code} 
    end
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
    @@attributes.each do |indicator_name, indicator|
      indicator_code = indicator[:code]
      debug = false
      begin
        response = db_request("countries/#{country[:id]}/indicators/#{indicator_code}", {:date => "2000:2012", :MRV => 1}, debug)
        country[indicator_name] = response[0]["value"].to_f unless response.nil? or response[0].nil?
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

  def get_attributes_info
    @countries.each do |code, country|
      @attributes.each do |attr, indicator|
        value = country[attr]
        indicator.set_if_greater(:max, value)
        indicator.set_if_smaller(:min, value)
      end
    end

    @attributes.each do |indicator_name, indicator|
      indicator_code = indicator[:code]
      response = db_request("/indicators/#{indicator_code}")
      next if response.nil? or response[0].nil?
      indicator[:name] = response[0]["name"]
      indicator[:description] = response[0]["sourceNote"]
      indicator[:source] = response[0]["source"]["value"] unless response[0]["source"].nil?
    end
  end

  def load_from_data_bank!
    @attributes.each do |indicator_name, indicator|
      indicator_code = indicator[:code]
      response = db_request("/countries/all/indicators/#{indicator_code}", {:date => "2000:2012", :MRV => 1})
      next if response.nil?
      response.each do |c|
        next unless @countries.has_key? c["country"]["id"]
        @countries[c["country"]["id"]][indicator_name] = c["value"].to_f unless c["value"].nil?
      end
    end
  end

  def export_to_csv(file, nil_replacement = "ND")
    CSV.open(file, "wb") do |csv|
      csv << first.keys
      each do |i|
        csv << i.values.map { |x| (x.nil?)?nil_replacement:x}
      end
    end
  end

  def export_to_json(file)
    @countries.export_to_json(file)
  end

  def scale_hash
    scale = @countries.clone
    
    scale.each do |code, country|
      @attributes.each do |attr, indicator|
        max = indicator[:max]
        min = indicator[:min]
        value = country[attr]
        next if value.nil? or max.nil? or min.nil?
        country[attr] = ((value-min)/(max-min))*100
      end
    end

    scale
  end
end

countries = CountryList.new
puts "Getting country list..."
countries.populate_from_data_bank!
puts "#{countries.count} countries found."
puts "Getting data for each country..."
countries.load_from_data_bank!
puts "Getting indicator info..."
countries.get_attributes_info
puts "Exporting to countries.csv..."
countries.export_to_csv("data/countries.csv")
puts "Exporting to countries.json..."
countries.export_to_json("data/countries.json")
puts "Exporting attributes to attributes.json..."
countries.attributes.export_to_json("data/attributes.json")
puts "Calculating scale hash..."
scale = countries.scale_hash
puts "Exporting scale hash to scale.json..."
scale.export_to_json("data/scale.json")
puts "All done."

