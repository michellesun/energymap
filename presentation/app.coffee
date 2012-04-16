window.styles = {
  "border_color": "#1C1C1C",
  "selected_border_color": "#FCD31C",
  "border_width": 1,
  "selected_border_width": 2,
  "default_fill": "#8A8A8A"
  "fill_colors": ["#229E00" , "#1D5E0B","#B0B818", "#F0C348", "#DE8100","#F06537","#D3D02", "#A62C03", "#731E02","#631900", "#631900"]
}

fnum = (n, cur = "") ->
  return "No data" if isNaN(n)
  f = {12: "trillion", 9: "billion", 6: "million", 3: "thousand"}
  for v in [12, 9, 6, 3]
    if n>=Math.pow(10, v)
      return "#{(n/Math.pow(10, v)).toFixed(2)} #{f[v]}" + " " + cur
  n.toFixed(2) + " " + cur

class App
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
    @view = "co2_emisssions"

  start: ->
    $.getJSON "data/world_svg_paths_by_code.json", @drawMap
    app = this
    $("#select-view").click (e) ->
      app.changeView(e.target.id)

  changeView: (view)->
    $("#select-view").children().removeClass("active")
    $("#select-view > ##{view}").addClass("active")
    @view = view
    for country, val of @borders
      @attr[country]["fill"] = @countryColor(country)
      @colorCountry(country, 500)


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

  countryColor: (country) ->
    if !@iso2code[country]
      return window.styles["default_fill"]
    value = @scaled_data[@iso2code[country]][@view]
    if !value 
      window.styles["default_fill"]
    else
      window.styles["fill_colors"][Math.floor(value/10)]
  
  getLegend: (country) ->
    c = @data[@iso2code[country]]
    ind = ['energy_production', 'energy_use', 'gdp_per_energy_use', 'alternative_energy_perc', 'energy_imports_perc', 'road_sector_energy_use_perc', 'electric_power_consumption_per_capita', 'co2_emisssions', 'co2_emissions_per_capita', 'motor_vehicles_per_1000_people', 'urban_population_perc']
    html = "<h2>#{c.name}</h2><span id='general_info'>GDP: #{fnum(c.gdp, "USD")}</span><table id='data'><tbody>"
    for i in ind
        html += "<tr><td>#{@attributes[i].name}</td><td>#{fnum(@data[@iso2code[country]][i])}</td></tr>"
    html += "</tbody></table>"
    html

  unselectCountry: () ->
    return if @selected_country == null
    @attr[@selected_country].stroke = window.styles["border_color"]
    @attr[@selected_country].stroke_width = window.styles["border_width"]
    @colorCountry(@selected_country, 500)
    @selected_country = null

  selectCountry: (country) ->
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

  colorCountry: (country, time=1) ->
    return unless @borders.hasOwnProperty(country)
    for i in [0...@borders[country].length]
      @borders[country][i].animate({"stroke": @attr[country].stroke, "fill": @attr[country].fill, "stroke-width": @attr[country].stroke_width}, time)


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

window.onload = () ->
  Raphael("map", 1200, 600, ->
    paper = this
    app = new App(paper, 1200, 600)
  )
  $("#legend").draggable()
