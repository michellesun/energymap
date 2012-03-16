require 'test/unit'
load 'collect.rb'

class CountryTest < Test::Unit::TestCase
  def test_constructor_error_checking
    assert_raise(ArgumentError) do
      country = Country.new
    end

    assert_raise(UnknownCountryCode) do
      country = Country.new("trololom")
    end
  end
end
