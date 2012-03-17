(function() {
  var cancelEvent, start;

  cancelEvent = function(e) {
    e = (e ? e : window.event);
    if (e.stopPropagation) e.stopPropagation();
    if (e.preventDefault) e.preventDefault();
    e.cancelBubble = true;
    e.cancel = true;
    e.returnValue = false;
    return false;
  };

  start = function() {
    var country, hue, out, over, r, world;
    r = this;
    r.rect(0, 0, 1000, 400, 10).attr({
      stroke: "none",
      fill: "#333333"
    });
    over = function() {
      this.c = this.c || this.attr("fill");
      return this.stop().animate({
        fill: "#bacabd"
      }, 500);
    };
    out = function() {
      return this.stop().animate({
        fill: this.c
      }, 500);
    };
    r.setStart();
    hue = Math.random();
    world = window.world;
    for (country in world.shapes) {
      r.path(world.shapes[country]).attr({
        stroke: "#ccc6ae",
        fill: "#f0efeb",
        "stroke-opacity": 0.25
      });
    }
    world = r.setFinish();
    world.hover(over, out);
    world.getXY = function(lat, lon) {
      return {
        cx: lon * 2.6938 + 465.4,
        cy: lat * -2.6938 + 227.066
      };
    };
    world.getLatLon = function(x, y) {
      return {
        lat: (y - 227.066) / -2.6938,
        lon: (x - 465.4) / 2.6938
      };
    };
    return document.getElementById("map").addEventListener('mousewheel', function(event) {
      console.log(event.wheelDelta / 120);
      r.setViewBox(500, 200, 500, 200, false);
      return cancelEvent(event);
    }, false);
  };

  Raphael("map", 1000, 400, start);

}).call(this);
