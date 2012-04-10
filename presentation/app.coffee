window.styles = {
  "border_color": "#1C1C1C",
  "selected_border_color": "#FCD31C",
  "border_width": 1,
  "selected_border_width": 2,
  "default_fill": "#8A8A8A"
  "fill_colors": ["#229E00" , "#1D5E0B","#B0B818", "#F0C348", "#DE8100","#F06537","#D3D02", "#A62C03", "#731E02","#631900", "#631900"]
}

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

  start: ->
    console.log @scaled_data
    $.getJSON "data/world_svg_paths_by_code.json", @drawMap

  getData: ->
    app = this
    $.getJSON "data/attributes.json", (data) ->
      app.attributes = data
      $.getJSON "data/countries.json", (data) ->
        app.data = data
        for iso2code, country of data
          console.log iso2code
          app.iso2code[country["id"]] = iso2code
        $.getJSON "data/scale.json", (data) ->
          app.scaled_data = data
          app.start()

  countryColor: (country) ->
    if !@iso2code[country]
      return window.styles["default_fill"]
    value = @scaled_data[@iso2code[country]].co2_emisssions
    if !value 
      window.styles["default_fill"]
    else
      window.styles["fill_colors"][Math.floor(value/10)]
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
    @selected_country = country

  getClickHandler: (country) ->
    app = this
    return ->
      app.unselectCountry()
      app.selectCountry(country)

  colorCountry: (country, time=1) ->
    return unless @borders.hasOwnProperty(country)
    for i in [0...@borders[country].length]
      @borders[country][i].attr({"stroke": @attr[country].stroke, "fill": @attr[country].fill, "stroke-width": @attr[country].stroke_width})


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
