# Goal: To build a script that collects and organizes data per country. For now, the only source will be the data world bank.
# The collector should collect the following data for every country: GDP, energy production, energy use

require 'open-uri'

class UnknownCountryCode < Exception
end

class String
  def country_name
    
  end
end

class Country
  attr_accessor :gdp, :energy_production, :energy_use

  def initialize(code, gdp = nil, energy_production = nil, energy_use = nil)
    @code = code
    @name = code.country_name
    raise UnknownCountry if @name.nil?
    @gdp = gdp
    @energy_production = energy_production
    @energy_use = energy_use
  end

  def load_from_data_bank
  end
end

class CountryList < Array
  def initialize
    super
  end
  
  def populate_from_data_bank
    
  end

  def load_from_data_bank

  end
end
puts "Energy Data Analysis Project"
puts "------ Data collector ------"



