(function() {
  var App, fnum, hsvToRgb,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.styles = {
    "border_color": "#1C1C1C",
    "selected_border_color": "#FCD31C",
    "border_width": 1,
    "selected_border_width": 2,
    "default_fill": "#8A8A8A"
  };

  fnum = function(n, cur) {
    var f, v, _i, _len, _ref;
    if (cur == null) cur = "";
    if (isNaN(n)) return "No data";
    f = {
      12: "trillion",
      9: "billion",
      6: "million",
      3: "thousand"
    };
    _ref = [12, 9, 6, 3];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      v = _ref[_i];
      if (n >= Math.pow(10, v)) {
        return ("" + ((n / Math.pow(10, v)).toFixed(2)) + " " + f[v]) + " " + cur;
      }
    }
    return n.toFixed(2) + " " + cur;
  };

  hsvToRgb = function(h, s, v) {
    var b, f, g, i, p, q, r, t;
    r = void 0;
    g = void 0;
    b = void 0;
    i = Math.floor(h * 6);
    f = h * 6 - i;
    p = v * (1 - s);
    q = v * (1 - f * s);
    t = v * (1 - (1 - f) * s);
    switch (i % 6) {
      case 0:
        r = v;
        g = t;
        b = p;
        break;
      case 1:
        r = q;
        g = v;
        b = p;
        break;
      case 2:
        r = p;
        g = v;
        b = t;
        break;
      case 3:
        r = p;
        g = q;
        b = v;
        break;
      case 4:
        r = t;
        g = p;
        b = v;
        break;
      case 5:
        r = v;
        g = p;
        b = q;
    }
    return [r * 255, g * 255, b * 255];
  };

  App = (function() {

    function App(paper, width, height) {
      this.drawMap = __bind(this.drawMap, this);      this.paper = paper;
      this.width = width;
      this.height = height;
      this.borders = {};
      this.attr = {};
      this.iso2code = {};
      this.attributes = null;
      this.data = null;
      this.scaled_data = null;
      this.selected_country = null;
      this.getData();
      this.view = "co2_emissions_per_capita";
    }

    App.prototype.start = function() {
      var app;
      $.getJSON("data/world_svg_paths_by_code.json", this.drawMap);
      app = this;
      return $("#select-view").click(function(e) {
        return app.changeView(e.target.id);
      });
    };

    App.prototype.changeView = function(view) {
      var country, val, _ref, _results;
      $("#select-view .button-group").children().removeClass("active");
      $("#select-view #" + view).addClass("active");
      this.view = view;
      _ref = this.borders;
      _results = [];
      for (country in _ref) {
        val = _ref[country];
        this.attr[country]["fill"] = this.countryColor(country);
        _results.push(this.colorCountry(country, 500));
      }
      return _results;
    };

    App.prototype.getData = function() {
      var app;
      app = this;
      return $.getJSON("data/attributes.json", function(data) {
        app.attributes = data;
        return $.getJSON("data/countries.json", function(data) {
          var country, iso2code;
          app.data = data;
          for (iso2code in data) {
            country = data[iso2code];
            app.iso2code[country["id"]] = iso2code;
          }
          return $.getJSON("data/scale.json", function(data) {
            app.scaled_data = data;
            return app.start();
          });
        });
      });
    };

    App.prototype.countryColor = function(country, attr) {
      var rgb, value;
      if (attr === void 0) attr = this.view;
      if (!this.iso2code[country]) return window.styles["default_fill"];
      value = this.scaled_data[this.iso2code[country]][attr];
      if (!value) return window.styles["default_fill"];
      rgb = hsvToRgb((100 - value) / 360, 1, 1);
      return "rgb(" + (Math.floor(rgb[0])) + ", " + (Math.floor(rgb[1])) + ", " + (Math.floor(rgb[2])) + ")";
    };

    App.prototype.getLegend = function(country) {
      var c, html, i, ind, _i, _len;
      c = this.data[this.iso2code[country]];
      if (c === void 0) return "<h2>No Data</h2>";
      ind = ['energy_production', 'energy_use', 'gdp_per_energy_use', 'alternative_energy_perc', 'energy_imports_perc', 'road_sector_energy_use_perc', 'electric_power_consumption_per_capita', 'co2_emisssions', 'co2_emissions_per_capita', 'motor_vehicles_per_1000_people', 'urban_population_perc', 'diesel_fuel_price'];
      html = "<h2>" + c.name + "</h2><span id='general_info' class='color-" + (Math.ceil(this.scaled_data[this.iso2code[country]][i] / 100 * 3)) + "'>GDP: " + (fnum(c.gdp, "USD")) + "</span><table id='data'><tbody>";
      for (_i = 0, _len = ind.length; _i < _len; _i++) {
        i = ind[_i];
        html += "<tr><td class = 'name'>" + this.attributes[i].name + "</td><td class='value color-" + (Math.ceil(this.scaled_data[this.iso2code[country]][i] / 100 * 3)) + "'>" + (fnum(this.data[this.iso2code[country]][i])) + "</td></tr>";
      }
      html += "</tbody></table>";
      return html;
    };

    App.prototype.unselectCountry = function() {
      if (this.selected_country === null) return;
      this.attr[this.selected_country].stroke = window.styles["border_color"];
      this.attr[this.selected_country].stroke_width = window.styles["border_width"];
      this.colorCountry(this.selected_country, 500);
      return this.selected_country = null;
    };

    App.prototype.selectCountry = function(country) {
      console.log("Selecting country");
      if (!(this.borders.hasOwnProperty(country) && this.selected_country !== country)) {
        return;
      }
      this.attr[country].stroke = window.styles["selected_border_color"];
      this.attr[country].stroke_width = window.styles["selected_border_width"];
      this.colorCountry(country, 500);
      $("#legend").html(this.getLegend(country));
      return this.selected_country = country;
    };

    App.prototype.getClickHandler = function(country) {
      var app;
      app = this;
      return function() {
        app.unselectCountry();
        return app.selectCountry(country);
      };
    };

    App.prototype.colorCountry = function(country, time) {
      var i, _ref, _results;
      if (time == null) time = 1;
      if (!this.borders.hasOwnProperty(country)) return;
      _results = [];
      for (i = 0, _ref = this.borders[country].length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
        _results.push(this.borders[country][i].animate({
          "stroke": this.attr[country].stroke,
          "fill": this.attr[country].fill,
          "stroke-width": this.attr[country].stroke_width
        }, time));
      }
      return _results;
    };

    App.prototype.drawMap = function(data) {
      var country, i, line, path, val, _ref, _results;
      _results = [];
      for (country in data) {
        val = data[country];
        this.borders[country] = [];
        line = null;
        path = null;
        this.attr[country] = {
          stroke: window.styles["border_color"],
          fill: this.countryColor(country),
          stroke_width: window.styles["border_width"]
        };
        for (i = 0, _ref = val.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
          line = this.paper.path(val[i]);
          line.country = country;
          $(line.node).click(this.getClickHandler(country));
          this.borders[country].push(line);
        }
        _results.push(this.colorCountry(country));
      }
      return _results;
    };

    return App;

  })();

  $(function() {
    return Raphael("map", 1200, 600, function() {
      var app, paper;
      paper = this;
      return app = new App(paper, 1200, 600);
    });
  });

}).call(this);
