# The Energy Map 
**Under active development. This project is functional, but not yet complete.**

An interactive world map visualizing energy related data.  Data collector code in Ruby. Coffeescript, HAML, SASS for the presentation. Animations by Raphael.js. Also using jquery and jquery-ui (I plan on removing the jquery dependencies soon). All data from the [World Data Bank](http://data.worldbank.org/).

Inspired by [MigrationsMap.net](https://github.com/madewulf/MigrationsMap.net).

## Technical Information
The project is composed of two main parts:
### Data Collection
Code in collector/collect.rb
collect.rb is a ruby script that ollects data from the world data API and exports it in JSON format (and CSV for some files).

### Presentation
Code in presentation/
The website doesn't make any direct calls to the API; instead, it loads the .json files produced by the collect.rb script to display the map.

## Statistical Information
For each indicator and country, the most recent available value is being used (excluding values older than 10 years). Be aware, that means that two indicator values for two different countries might not be of the same date. All data from the [World Data Bank](http://data.worldbank.org/). You are free to use any of the produced data files (described below) for your own project.
### Files
All data files are locaed in presentation/data.

* attributes.json - Information about each indicator used by the app.
* countries.json - The actual data, per country. Keys are ISO2 country codes.
* countries.csv - The exact same data as above, in csv format. Not used in the actual app.
* scale.json - Contains the same data as above, in a 0..100 scale, 0 being the worldwide-minimum value and 100 being the worldwide-maximum one. Useful for coloring countries in the map.

## Contributions / Contact
For any questions, feel free to drop me a message.
Any kind of patches are always very welcome. No compulsory coding styles here :)
