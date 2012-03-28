window.colors = {
  "unselected_country": "#A1A1A1",
  "selected_country": "#999",
  "border": "#999"
}

class App
  constructor: (paper, width, height) ->
    @paper = paper
    @width = width
    @height = height
    @borders = {}
    @iso2code = {}
    @attributes = null
    @data = null
    @scaled_data = null
    @getData()

  start: ->
    console.log @attributes
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
      return window.colors["unselected_country"]
    value = @scaled_data[@iso2code[country]].co2_emissions_per_capita
    if !value 
      return window.colors["unselected_country"]
    if value < 20
      return "#075E02"
    else if value < 50
      return "#8F7E00"
    else if value < 80
      return "#BA0707"
    else
      return "#750000"

  drawMap: (data) =>
      for country, val of data
        @borders[country] = []
        line = null
        path = null
        for i in [0..val.length]
          line = @paper.path(val[i])
          line.attr
            stroke: window.colors["border"]
            "stroke-width": 1
            fill: @countryColor(country)
          line.country = country
          @borders[country].push line

window.onload = () ->
  Raphael("map", 1200, 600, ->
    paper = this
    app = new App(paper, 1200, 600)
  )
