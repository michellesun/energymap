# The Energy Map 
**Under active development. This project is functional, but not yet complete.**

An interactive world map visualizing energy related data.  Data collector code in Ruby. Coffeescript, HAML, SASS for the presentation. Animations by Raphael.js. Also using jquery and jquery-ui (I plan on removing the jquery dependencies soon). All data from the [World Data Bank](http://data.worldbank.org/).

[Live Demo](http://chrisp.gr/projects/energymap/)

Inspired by [MigrationsMap.net](https://github.com/madewulf/MigrationsMap.net).

## Technical Information
The project is composed of two main parts:

## Technical Information
The project is composed of two main parts:

### Data Collection
A ruby script that collects all availabe data from the world data bank using their official API. The data is then exported to 3 JSON files. Some files are also exported as CSV files. The script generates the following files:

* attributes.json - Information about each indicator used by the app. Includes information like every indicator's world data bank ID, a description of the indicator and the world maximum and world minimum values.
* countries.json - The actual data, per country. Keys are ISO2 country codes. This is a hash of countries, where each country looks like this: "<countrycode>":{"<attribute-name-1>: <attribute-value>, "<attribute-name-2>: <attribute-value>, [...]}. Attributes include both data indicators and information about the country itself, like it's name, iso2code etc.
* countries.csv - The exact same data as above, in csv format. Not used in the actual app.
* scale.json - Contains the same data as above, in a 0..100 scale, 0 being the worldwide-minimum value and 100 being the worldwide-maximum one. Useful for coloring countries in the map. The values are calculated using the following simple formula: ((value-min)/(max-min))*100

### Presentation
A website written in HAML, SASS and Coffeescript (which compile to HTML, CSS and Javascript). It uses jquery, jquery-ui and raphael.js The website doesn't make any direct calls to the World Data Bank API; instead, it loads the .json file produced by the collect.rb script to draw an SVG map. The map includes a legend that displays information about the selected country.

For coloring countries, the scale.json file is used (described above). It contains values in a 0..100 range. Then, the HSV (0..1 range) color is: (100-value)/360, 1, 1. In other words, red indicates a high value and green a low one.

## Statistical Information
For each indicator and country, the most recent available value is being used (excluding values older than 10 years). Be aware, that means that two indicator values for two different countries might not be of the same date. All data comes from the World Data Bank. You are free to use any of the produced data files (described below) for your own project.

## Contributions / Contact
Any questions? Feel free to drop me a message at [christos.porios@gmail.com](http://christos.porios@gmail.com). For suggestions/issues please use [Github](https://github.com/tech-no-crat/energymap).

Patches are always welcome, no compulsory coding styles here.

