# Some configuration options
window.styles = {
  "border_color": "#1C1C1C",
  "selected_border_color": "#FCD31C",
  "border_width": 1,
  "selected_border_width": 2,
  "default_fill": "#8A8A8A"
}

# Formats a number.
fnum = (n, cur = "") ->
  return "No data" if isNaN(n)
  f = {12: "trillion", 9: "billion", 6: "million", 3: "thousand"}
  for v in [12, 9, 6, 3]
    if n>=Math.pow(10, v)
      return "#{(n/Math.pow(10, v)).toFixed(2)} #{f[v]}" + " " + cur
  n.toFixed(2) + " " + cur

# Taken from http://mjijackson.com/2008/02/rgb-to-hsl-and-rgb-to-hsv-color-model-conversion-algorithms-in-javascript
# Takes an hsv triplet in the 0..1 range, returns rgb triplet in the 0..255 range
hsvToRgb = (h, s, v) ->
  r = undefined
  g = undefined
  b = undefined
  i = Math.floor(h * 6)
  f = h * 6 - i
  p = v * (1 - s)
  q = v * (1 - f * s)
  t = v * (1 - (1 - f) * s)
  switch i % 6
    when 0
      r = v
      g = t
      b = p
    when 1
      r = q
      g = v
      b = p
    when 2
      r = p
      g = v
      b = t
    when 3
      r = p
      g = q
      b = v
    when 4
      r = t
      g = p
      b = v
    when 5
      r = v
      g = p
      b = q
  [ r * 255, g * 255, b * 255 ]

# The map app
class App
  # Constructor, 'paper' is a Raphael.js pre-configured paper.
  constructor: (paper, width, height) ->
    @paper = paper
    @width = width
    @height = height
    @borders = {}
    @attr = {}
    @iso2code = {}
    @attributes = null
    @data = null
    @scaled_data = null
    @selected_country = null
    @getData()
    @view = "co2_emissions_per_capita"

  # Starts (= draws) the map
  start: ->
    $.getJSON "data/world_svg_paths_by_code.json", @drawMap
    app = this
    $("#select-view").click (e) ->
      app.changeView(e.target.id)

  # Changes the map view (= what attribute the map currently displays)
  changeView: (view)->
    $("#select-view .button-group").children().removeClass("active")
    $("#select-view ##{view}").addClass("active")
    @view = view
    for country, val of @borders
      @attr[country]["fill"] = @countryColor(country)
      @colorCountry(country, 500)

  # Gets data. Any ways to make this function less ugly? - javascript noob
  getData: ->
    app = this
    $.getJSON "data/attributes.json", (data) ->
      app.attributes = data
      $.getJSON "data/countries.json", (data) ->
        app.data = data
        for iso2code, country of data
          app.iso2code[country["id"]] = iso2code
        $.getJSON "data/scale.json", (data) ->
          app.scaled_data = data
          app.start()

  # Returns the color for a country, by using the values in the scale.json file.
  countryColor: (country, attr) ->
    attr = @view if attr == undefined

    if !@iso2code[country]
      return window.styles["default_fill"]
    value = @scaled_data[@iso2code[country]][attr]
    if !value 
      return window.styles["default_fill"]
    rgb = hsvToRgb((100-value)/360, 1, 1)
    
    "rgb(#{Math.floor(rgb[0])}, #{Math.floor(rgb[1])}, #{Math.floor(rgb[2])})"
    
  # Returns the Legend's HTML
  getLegend: (country) ->
    c = @data[@iso2code[country]]
    return "<h2>No Data</h2>" if c == undefined
    ind = ['energy_production', 'energy_use', 'gdp_per_energy_use', 'alternative_energy_perc', 'energy_imports_perc', 'road_sector_energy_use_perc', 'electric_power_consumption_per_capita', 'co2_emisssions', 'co2_emissions_per_capita', 'motor_vehicles_per_1000_people', 'urban_population_perc', 'diesel_fuel_price']
    html = "<h2>#{c.name}</h2><span id='general_info' class='color-#{Math.ceil(@scaled_data[@iso2code[country]][i]/100 * 3)}'>GDP: #{fnum(c.gdp, "USD")}</span><table id='data'><tbody>"
    for i in ind
        html += "<tr><td class = 'name'>#{@attributes[i].name}</td><td class='value color-#{Math.ceil(@scaled_data[@iso2code[country]][i]/100 * 3)}'>#{fnum(@data[@iso2code[country]][i])}</td></tr>"
    html += "</tbody></table>"
    html

  # Unselects the currently selected country
  unselectCountry: () ->
    return if @selected_country == null
    @attr[@selected_country].stroke = window.styles["border_color"]
    @attr[@selected_country].stroke_width = window.styles["border_width"]
    @colorCountry(@selected_country, 500)
    @selected_country = null

  # Selects the given country
  selectCountry: (country) ->
    console.log "Selecting country"
    return unless @borders.hasOwnProperty(country) and @selected_country != country
    @attr[country].stroke = window.styles["selected_border_color"]
    @attr[country].stroke_width = window.styles["selected_border_width"]
    @colorCountry(country, 500)
    $("#legend").html(@getLegend(country))
    @selected_country = country

  getClickHandler: (country) ->
    app = this
    return ->
      app.unselectCountry()
      app.selectCountry(country)

  # Animates a color change for the given country in a given time.
  colorCountry: (country, time=1) ->
    return unless @borders.hasOwnProperty(country)
    for i in [0...@borders[country].length]
      @borders[country][i].animate({"stroke": @attr[country].stroke, "fill": @attr[country].fill, "stroke-width": @attr[country].stroke_width}, time)

  # Draws the SVG map
  drawMap: (data) =>
      for country, val of data
        @borders[country] = []
        line = null
        path = null
        @attr[country] = {stroke: window.styles["border_color"], fill: @countryColor(country), stroke_width: window.styles["border_width"]}
        for i in [0...val.length]
          line = @paper.path(val[i])
          line.country = country
          $(line.node).click(@getClickHandler(country))
          @borders[country].push line
        @colorCountry(country)

$( ->
  Raphael("map", 1200, 600, ->
    paper = this
    app = new App(paper, 1200, 600)
  )
)
