(function() {
  var App, fnum,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.styles = {
    "border_color": "#1C1C1C",
    "selected_border_color": "#FCD31C",
    "border_width": 1,
    "selected_border_width": 2,
    "default_fill": "#8A8A8A",
    "fill_colors": ["#229E00", "#1D5E0B", "#B0B818", "#F0C348", "#DE8100", "#F06537", "#D3D02", "#A62C03", "#731E02", "#631900", "#631900"]
  };

  fnum = function(n) {
    var f, v, _i, _len, _ref;
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
        return "" + ((n / Math.pow(10, v)).toFixed(2)) + " " + f[v];
      }
    }
    return n;
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
    }

    App.prototype.start = function() {
      console.log(this.scaled_data);
      return $.getJSON("data/world_svg_paths_by_code.json", this.drawMap);
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
            console.log(iso2code);
            app.iso2code[country["id"]] = iso2code;
          }
          return $.getJSON("data/scale.json", function(data) {
            app.scaled_data = data;
            return app.start();
          });
        });
      });
    };

    App.prototype.countryColor = function(country) {
      var value;
      if (!this.iso2code[country]) return window.styles["default_fill"];
      value = this.scaled_data[this.iso2code[country]].co2_emisssions;
      if (!value) {
        return window.styles["default_fill"];
      } else {
        return window.styles["fill_colors"][Math.floor(value / 10)];
      }
    };

    App.prototype.getLegend = function(country) {
      var c;
      c = this.data[this.iso2code[country]];
      return "<h2>" + c.name + "</h2><p id='general_info'>GDP: " + (fnum(c.gdp)) + " USD";
    };

    App.prototype.unselectCountry = function() {
      if (this.selected_country === null) return;
      this.attr[this.selected_country].stroke = window.styles["border_color"];
      this.attr[this.selected_country].stroke_width = window.styles["border_width"];
      this.colorCountry(this.selected_country, 500);
      return this.selected_country = null;
    };

    App.prototype.selectCountry = function(country) {
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
        _results.push(this.borders[country][i].attr({
          "stroke": this.attr[country].stroke,
          "fill": this.attr[country].fill,
          "stroke-width": this.attr[country].stroke_width
        }));
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

  window.onload = function() {
    Raphael("map", 1200, 600, function() {
      var app, paper;
      paper = this;
      return app = new App(paper, 1200, 600);
    });
    return $("#legend").draggable();
  };

}).call(this);
