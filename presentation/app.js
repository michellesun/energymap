(function() {
  var App,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.colors = {
    "unselected_country": "#A1A1A1",
    "selected_country": "#999",
    "border": "#999"
  };

  App = (function() {

    function App(paper, width, height) {
      this.drawMap = __bind(this.drawMap, this);      this.paper = paper;
      this.width = width;
      this.height = height;
      this.borders = {};
      this.iso2code = {};
      this.attributes = null;
      this.data = null;
      this.scaled_data = null;
      this.getData();
    }

    App.prototype.start = function() {
      console.log(this.attributes);
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
      if (!this.iso2code[country]) return window.colors["unselected_country"];
      value = this.scaled_data[this.iso2code[country]].co2_emissions_per_capita;
      if (!value) return window.colors["unselected_country"];
      if (value < 20) {
        return "#075E02";
      } else if (value < 50) {
        return "#8F7E00";
      } else if (value < 80) {
        return "#BA0707";
      } else {
        return "#750000";
      }
    };

    App.prototype.drawMap = function(data) {
      var country, i, line, path, val, _results;
      _results = [];
      for (country in data) {
        val = data[country];
        this.borders[country] = [];
        line = null;
        path = null;
        _results.push((function() {
          var _ref, _results2;
          _results2 = [];
          for (i = 0, _ref = val.length; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
            line = this.paper.path(val[i]);
            line.attr({
              stroke: window.colors["border"],
              "stroke-width": 1,
              fill: this.countryColor(country)
            });
            line.country = country;
            _results2.push(this.borders[country].push(line));
          }
          return _results2;
        }).call(this));
      }
      return _results;
    };

    return App;

  })();

  window.onload = function() {
    return Raphael("map", 1200, 600, function() {
      var app, paper;
      paper = this;
      return app = new App(paper, 1200, 600);
    });
  };

}).call(this);
