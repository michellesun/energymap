cancelEvent = (e) ->
  e = (if e then e else window.event)
  e.stopPropagation()  if e.stopPropagation
  e.preventDefault()  if e.preventDefault
  e.cancelBubble = true
  e.cancel = true
  e.returnValue = false
  false

start = ->
  r = this
  r.rect(0, 0, 1000, 400, 10).attr
    stroke: "none"
    fill: "#333333"

  over = ->
    @c = @c or @attr("fill")
    @stop().animate
      fill: "#bacabd"
    , 500

  out = ->
    @stop().animate
      fill: @c
    , 500

  r.setStart()
  hue = Math.random()
  world = window.world
  for country of world.shapes
    r.path(world.shapes[country]).attr
      stroke: "#ccc6ae"
      fill: "#f0efeb"
      "stroke-opacity": 0.25
  world = r.setFinish()
  world.hover over, out
  world.getXY = (lat, lon) ->
    cx: lon * 2.6938 + 465.4
    cy: lat * -2.6938 + 227.066

  world.getLatLon = (x, y) ->
    lat: (y - 227.066) / -2.6938
    lon: (x - 465.4) / 2.6938
  
  zoomlevel = 1
  document.getElementById("map").addEventListener('mousewheel',  (event) ->
    console.log(event.wheelDelta/120)
    
    r.setViewBox(500, 200, 500, 200, false)

    return cancelEvent(event)
  , false)

Raphael("map", 1000, 400, start)
